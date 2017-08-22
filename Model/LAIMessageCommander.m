#import "LAIGlobalHeader.h"

static LAIMessageCommander *sharedCommander;

@implementation LAIMessageCommander

+ (void)initialize
{
	if (self == [LAIMessageCommander class]) sharedCommander = [[self alloc] init];
}

+ (instancetype)sharedCommander
{
	return sharedCommander;
}

- (void)sendMessage:(CMessageWrap *)wrap
{
	@autoreleasepool
	{
		LAIUserCommander *userCommander = [LAIUserCommander sharedCommander];
		NSString *receiver = wrap.m_nsToUsr;
		if (([wrap LAIIsToGroup] && [userCommander amIInGroup:receiver]) || (![wrap LAIIsToGroup] && [userCommander isContact:receiver]))
		{
			__unsafe_unretained __block LAIMessageCommander *weakSelf = self;
			[globalQueue addOperationWithBlock:^{
				@autoreleasepool
				{
					globalQueue.suspended = YES;
					[weakSelf waitWithMessage:wrap];
					switch (wrap.m_uiMessageType)
					{
						case 1:
							{
								NSLog(@"LAI: Prepare to send text message \"%@\" to %@.", wrap.m_nsContent, [userCommander nameOfUser:receiver]);
								[globalMessageMgr AddMsg:receiver MsgWrap:wrap];
								break;
							}
						case 3:
							{
								NSLog(@"LAI: Prepare to send image message to %@.", [userCommander nameOfUser:receiver]);
								[globalMessageMgr AddMsg:receiver MsgWrap:wrap];
								break;
							}
						case 49:
							{
								NSLog(@"LAI: Prepare to send app message \"%@\" to %@.", wrap.m_nsAppMediaUrl, [userCommander nameOfUser:receiver]);
								[globalMessageMgr AddAppMsg:receiver MsgWrap:wrap Data:nil Scene:3];
								break;
							}
						default:
							{
								NSLog(@"LAI: Prepare to send unknown message \"%@\" to %@.", wrap, [userCommander nameOfUser:receiver]);
								[globalMessageMgr AddMsg:receiver MsgWrap:wrap];
								break;
							}
					}
				}				
			}];
		}
		else NSLog(@"LAI: %@ is not from a contact so we're not sending anything.", [userCommander nameOfUser:receiver]);
	}
}

- (void)waitWithMessage:(CMessageWrap *)wrap
{
	switch (wrap.m_uiMessageType)
	{
		case 1: // Text
			{
				sleep(1);
				break;
			}
		case 3: // Image
			{
				sleep(2);						
				break;
			}
		case 49: // App message
			{
				sleep(2);						
				break;
			}
		default:
			{
				sleep(1);						
				break;
			}
	}
}

- (CMessageWrap *)welcomeMessageWrapForWrap:(CMessageWrap *)wrap
{
	@autoreleasepool
	{
		NSString *senderID = wrap.m_nsFromUsr;
		NSString *content = wrap.m_nsContent;			
		NSString *startString = @" invited ";
		NSString *endString = @" to the group chat";
		NSUInteger startLocation = [content rangeOfString:startString].location;
		NSUInteger endLocation = [content rangeOfString:endString].location;
		if (startLocation == NSNotFound || endLocation == NSNotFound)
		{
			startString = @"";
			endString = @" joined the group chat ";
			startLocation = 0;
			endLocation = [content rangeOfString:endString].location;
		}
		NSString *userName = [content substringWithRange:NSMakeRange(startLocation + startString.length, endLocation - startLocation - startString.length)];
		NSString *welcomeMessage = [NSString stringWithFormat:[LAIPreferences welcomeMessage], userName];
		CMessageWrap *newWrap = [logicController FormTextMsg:senderID withText:welcomeMessage];
		return newWrap;
	}
}

- (void)handleGroupMessageWrap:(CMessageWrap *)wrap
{
	NSLog(@"LAI: Handle group message from %@", [[LAIUserCommander sharedCommander] nameOfUser:wrap.m_nsFromUsr]);
	switch (wrap.m_uiMessageType)
	{
		case 1:
			{
				[self handleTextMessageWrap:wrap];
				break;
			}
		case 10002:
			{
				if ([wrap LAIIsNewGroupMember])
				{
					CMessageWrap *welcomeMessageWrap = [self welcomeMessageWrapForWrap:wrap];
					[self sendMessage:welcomeMessageWrap];
				}
				break;
			}
	}
}

- (void)handlePrivateMessageWrap:(CMessageWrap *)wrap
{
	NSLog(@"LAI: Handle private message from %@", [[LAIUserCommander sharedCommander] nameOfUser:wrap.m_nsFromUsr]);
	switch (wrap.m_uiMessageType)
	{
		case 1:
			{
				[self handleTextMessageWrap:wrap];
				break;
			}
	}
}

- (void)handleTextMessageWrap:(CMessageWrap *)wrap
{
	@autoreleasepool
	{
		LAIGroupCommander *groupCommander = [LAIGroupCommander sharedCommander];
		LAIUserCommander *userCommander = [LAIUserCommander sharedCommander];
		NSString *sender = wrap.m_nsFromUsr;

		NSLog(@"LAI: Handle text message \"%@\" from %@ to %@.", wrap.m_nsContent, [userCommander nameOfUser:sender], [userCommander nameOfUser:wrap.m_nsToUsr]);

		if ([wrap LAIIsFriendAdded])
		{
			[groupCommander inviteUserToLaiGroup:sender];
		}
		else if ([wrap LAIIsNotifyCommand])
		{
			NSString *content = [wrap.m_nsContent stringByReplacingOccurrencesOfString:@"notify:" withString:@""];
			content = [content stringByReplacingOccurrencesOfString:@"Notify:" withString:@""];
			if (content.length != 0)
			{
				for (NSString *groupID in [LAIPreferences groups])
				{
					CMessageWrap *newWrap = [logicController FormTextMsg:groupID withText:content];					
					NSArray *groupMembers = [groupCommander membersOfGroup:groupID];
					NSMutableString *members = [@"" mutableCopy];
					for (CContact *groupMember in groupMembers)
					{
						[members appendString:groupMember.m_nsUsrName];
						[members appendString:@","];
					}
					[members deleteCharactersInRange:NSMakeRange(members.length - 1, 1)];
					newWrap.m_nsMsgSource = [[NSString alloc] initWithFormat:@"<msgsource><atuserlist>%@</atuserlist><membercount>%tu</membercount></msgsource>", members, groupMembers.count];
					[self sendMessage:newWrap];
				}
			}	
		}
	}
}

- (void)handleSystemMessageWrap:(CMessageWrap *)wrap
{
	if (wrap.m_n64MesSvrID != 0 && wrap.m_uiMessageType == 10000)
	{	
		NSLog(@"LAI: Handle system message \"%@\".", wrap.m_nsContent);

		LAIUserCommander *userCommander = [LAIUserCommander sharedCommander];
		LAIGroupCommander *groupCommander = [LAIGroupCommander sharedCommander];

		if (wrap.m_uiStatus == 4 && [wrap LAIIsNewGroupMember])
		{
			CMessageWrap *welcomeMessageWrap = [self welcomeMessageWrapForWrap:wrap];
			[self sendMessage:welcomeMessageWrap];
		}	
		else if ([wrap.m_nsContent isEqualToString:@"Too many attempts. Try again later."])
		{
			NSLog(@"LAI: Seems WeChat has detected our frequent messages.");
			[globalQueue cancelAllOperations];
			globalQueue.suspended = NO;
		}
		else if (![wrap LAIIsFromGroup])
		{
			NSString *userID = wrap.m_nsFromUsr;
			if ([wrap LAIIsFriendAdded])
			{
				[groupCommander inviteUserToLaiGroup:userID];
			}
			else if ([wrap LAIIsFriendRemoved]) [userCommander deleteUserAndSession:userID];
		}
	}
}

@end

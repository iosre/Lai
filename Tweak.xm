#import "Laibot.h"
#import "Model/LAIGlobalHeader.h"

%group WeChatHook

%hook CMessageMgr

static NSUInteger sendFailureCount;
CMessageMgr *globalMessageMgr;

- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap
{
	%orig;
	LAIMessageCommander *messageCommander = [LAIMessageCommander sharedCommander];
	if (![wrap LAIIsFromMe])
	{
		switch (wrap.m_uiStatus)
		{
			case 3: // Receive personal messages
				{
					if (![wrap LAIIsFromGroup])
					{
						[messageCommander handlePrivateMessageWrap:wrap];
					}
					else
					{
						[messageCommander handleGroupMessageWrap:wrap];
					}
					break;
				}
			case 4: // Receive system messages
				{
					[messageCommander handleSystemMessageWrap:wrap];
					break;
				}
		}
	}
}

- (void)AsyncOnModMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap
{
	%orig;
	LAIUserCommander *userCommander = [LAIUserCommander sharedCommander];
	if (wrap.m_uiStatus == 2)
	{
		globalQueue.suspended = NO;

		switch (wrap.m_uiMessageType)
		{
			case 1:
				{
					NSLog(@"LAI: Successfully sent text message \"%@\" to %@.", wrap.m_nsContent, [userCommander nameOfUser:wrap.m_nsToUsr]);
					break;
				}
			case 3:
				{
					NSLog(@"LAI: Successfully sent image message to %@.", [userCommander nameOfUser:wrap.m_nsToUsr]);
					break;
				}
			case 49:
				{
					NSLog(@"LAI: Successfully sent app message \"%@\" to %@.", wrap.m_nsAppMediaUrl, [userCommander nameOfUser:wrap.m_nsToUsr]);
					break;
				}
			default:
				{
					NSLog(@"LAI: Successfully sent unknown message \"%@\" to %@.", wrap, [userCommander nameOfUser:wrap.m_nsToUsr]);
					break;
				}
		}
		sendFailureCount = 0;
	}
	else if (wrap.m_uiStatus == 5)
	{
		globalQueue.suspended = NO;

		sendFailureCount++;
		if (sendFailureCount < 3)
		{
			switch (wrap.m_uiMessageType)
			{
				case 1:
					{
						NSLog(@"LAI: Failed to send text message \"%@\" to %@.", wrap.m_nsContent, [userCommander nameOfUser:wrap.m_nsToUsr]);
						break;
					}
				case 3:
					{
						NSLog(@"LAI: Failed to send image message to %@.", [userCommander nameOfUser:wrap.m_nsToUsr]);
						break;
					}
				case 49:
					{
						NSLog(@"LAI: Failed to send app message \"%@\" to %@.", wrap.m_nsAppMediaUrl, [userCommander nameOfUser:wrap.m_nsToUsr]);
						break;
					}
				default:
					{
						NSLog(@"LAI: Failed to send unknown message \"%@\" to %@.", wrap, [userCommander nameOfUser:wrap.m_nsToUsr]);
						break;
					}
			}
			NSLog(@"LAI: Resend it.");
			LAIMessageCommander *messageCommander = [LAIMessageCommander sharedCommander];			
			[messageCommander sendMessage:wrap];
		}
		else
		{
			NSLog(@"LAI: Too many sending failures. Pass and head on to the next message.");
			sendFailureCount = 0;
		}
	}
}

- (void)MessageReturn:(NSUInteger)flag MessageInfo:(NSDictionary *)info Event:(NSUInteger)arg3
{
	%orig;
	if (flag == 332) // Friend request
	{
		SayHelloViewController *controller = [[%c(SayHelloViewController) alloc] init];
		[controller initData];
		NSArray *wraps = info[@"27"];
		for (CMessageWrap *wrap in wraps)
		{
			CPushContact *contact = [%c(SayHelloDataLogic) getContactFrom:wrap];
			[controller verifyContactWithOpCode:contact opcode:3];
		}
		controller = nil;
	}
}

- (CMessageMgr *)init
{
	CMessageMgr *result = %orig;
	globalMessageMgr = result;
	return result;
}

%end

%hook MicroMessengerAppDelegate

- (BOOL)application:(UIApplication *)arg1 didFinishLaunchingWithOptions:(NSDictionary *)arg2
{
	BOOL result = %orig;
	[LAIPreferences initSettings];	
	[self LAIInitSettings];
	return result;
}

%end

%end

%ctor
{
	if ([[[NSProcessInfo processInfo] processName] isEqualToString:@"WeChat"])
	{
		if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0] hasPrefix:@"en"])
		{
			NSLog(@"LAI: Non-English environment, bye bye.");
			exit(66);
		}
		else %init(WeChatHook);
	}
}

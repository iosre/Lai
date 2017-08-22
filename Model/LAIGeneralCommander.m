#import "LAIGlobalHeader.h"

static LAIGeneralCommander *sharedCommander;

@implementation LAIGeneralCommander

+ (void)initialize
{
	if (self == [LAIGeneralCommander class]) sharedCommander = [[self alloc] init];
}

+ (instancetype)sharedCommander
{
	return sharedCommander;
}

- (BOOL)amIInGroup:(NSString *)groupID
{
	@autoreleasepool
	{
		LAIUserCommander *userCommander = [LAIUserCommander sharedCommander];
		CGroupMgr *groupMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CGroupMgr") class]];
		if ([groupMgr IsUsrInChatRoom:groupID Usr:[userCommander myID]]) return YES;
		return NO;
	}
}

- (void)promptDoNotDisturb
{
	@autoreleasepool
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"正在工作" message:@"请勿触碰" delegate:self cancelButtonTitle:@"好的，我保证不碰☺️" otherButtonTitles:nil];
		[alertView show];
		alertView = nil;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		[LAIPreferences initSettings];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self promptDoNotDisturb];
	});
}

- (NSString *)nameOfUser:(NSString *)userID
{
	return [self nameOfUser:userID inGroup:nil];
}

- (NSString *)nameOfUser:(NSString *)userID inGroup:(NSString *)groupID
{
	@autoreleasepool
	{
		NSString *userName = @"";
		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		CGroupMgr *groupManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CGroupMgr") class]];
		CContact *userContact = [contactManager getContactByName:userID];
		if (!groupID) userName = userContact.m_nsNickName;
		else
		{
			CContact *groupContact = [contactManager getContactByName:groupID];
			if (groupContact && [groupManager IsUsrInChatRoom:groupID Usr:userID])
			{
				userName = [groupContact getChatRoomMembrGroupNickName:userContact];
				if (userName.length == 0) userName = [groupContact getChatRoomMemberNickName:userContact];
			}
		}
		if (userName.length == 0) userName = userID;
		return userName;
	}
}

@end

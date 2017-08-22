#import "LAIGlobalHeader.h"

static LAIGroupCommander *sharedCommander;

@implementation LAIGroupCommander

+ (void)initialize
{
	if (self == [LAIGroupCommander class]) sharedCommander = [[self alloc] init];
}

+ (instancetype)sharedCommander
{
	return sharedCommander;
}

- (void)inviteUserToLaiGroup:(NSString *)userID
{
	CGroupMgr *manager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CGroupMgr") class]];
	LAIUserCommander *userCommander = [LAIUserCommander sharedCommander];
	[globalQueue addOperationWithBlock:^{
		@autoreleasepool
		{
			for (NSString *groupID in [LAIPreferences groups])
			{
				if ([userCommander amIInGroup:groupID] && ![manager IsUsrInChatRoom:groupID Usr:userID])
				{
					[manager InviteGroupMember:groupID withMemberList:@[userID]];
					sleep(2);
				}
			}
		}
	}];
}

- (NSArray *)membersOfGroup:(NSString *)groupID
{
	CGroupMgr *manager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CGroupMgr") class]];
	return [manager GetGroupMember:groupID];
}

@end

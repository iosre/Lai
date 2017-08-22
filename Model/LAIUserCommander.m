#import "LAIGlobalHeader.h"

static LAIUserCommander *sharedCommander;

@implementation LAIUserCommander

+ (void)initialize
{
	if (self == [LAIUserCommander class]) sharedCommander = [[self alloc] init];
}

+ (instancetype)sharedCommander
{
	return sharedCommander;
}

- (BOOL)isAdmin:(NSString *)userID
{
	@autoreleasepool
	{
		if ([[LAIPreferences admins] indexOfObject:userID] != NSNotFound) return YES;
		return NO;
	}
}

- (void)encodeUserAlias:(NSString *)userID // Change contact's remark to userID
{
	@autoreleasepool
	{
		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		CContact *userContact = [contactManager getContactByName:userID];
		userContact.m_nsRemark = userContact.m_nsUsrName;
		[contactManager setContact:userContact remark:userContact.m_nsRemark hideHashPhone:NO];
	}
}

- (void)deleteUserAndSession:(NSString *)userID
{
	@autoreleasepool
	{
		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		CContact *userContact = [contactManager getContactByName:userID];
		[contactManager deleteContact:userContact listType:2 andScene:0 sync:YES local:NO];
		[contactManager deleteContact:userContact listType:1 andScene:0 sync:NO local:YES];
		MMNewSessionMgr *sessionManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("MMNewSessionMgr") class]];
		[sessionManager DeleteSessionOfUser:userID];
	}
}

- (BOOL)isContact:(NSString *)userID
{
	@autoreleasepool
	{
		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		if (![contactManager getContactByName:userID]) return NO;
		return YES;
	}
}

- (NSString *)myID
{
	return [objc_getClass("SettingUtil") getLocalUsrName:0];
}

@end

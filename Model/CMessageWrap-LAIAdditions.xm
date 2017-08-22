#import "CMessageWrap-LAIAdditions.h"
#import "LAIPreferences.h"
#import "LAIUserCommander.h"

%hook CMessageWrap

%new
- (BOOL)LAIIsFromAdmin
{
	if ([[LAIPreferences admins] indexOfObject:self.m_nsFromUsr] != NSNotFound) return YES;
	return NO;
}

%new
- (BOOL)LAIIsFriendAdded
{
	if ([self.m_nsContent rangeOfString:@"as your WeChat contact"].location != NSNotFound || [self.m_nsContent rangeOfString:@"I've accepted your friend request. Now let's chat!"].location != NSNotFound) return YES;
	return NO;
}

%new
- (BOOL)LAIIsFriendRemoved
{
	if ([self.m_nsContent rangeOfString:@"The message is successfully sent but rejected by the receiver"].location != NSNotFound || [self.m_nsContent rangeOfString:@"has requested friend verification"].location != NSNotFound) return YES;
	return NO;
}

%new
- (BOOL)LAIIsNotifyCommand
{
	if ([self LAIIsFromAdmin] && ([self.m_nsContent hasPrefix:@"notify:"] || [self.m_nsContent hasPrefix:@"Notify:"])) return YES;
	return NO;
}

%new
- (BOOL)LAIIsFromGroup
{
	if ([self.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound) return YES;
	return NO;
}

%new
- (BOOL)LAIIsFromMe
{
	if ([self.m_nsFromUsr isEqualToString:[[LAIUserCommander sharedCommander] myID]]) return YES;
	return NO;
}

%new
- (BOOL)LAIIsToGroup
{
	if ([self.m_nsToUsr rangeOfString:@"@chatroom"].location != NSNotFound) return YES;
	return NO;
}

%new
- (BOOL)LAIIsNewGroupMember
{
	if (([self.m_nsContent rangeOfString:@" invited "].location != NSNotFound && [self.m_nsContent rangeOfString:@"invited you"].location == NSNotFound) || [self.m_nsContent rangeOfString:@" joined the group chat "].location != NSNotFound) return YES;
	return NO;
}

%end

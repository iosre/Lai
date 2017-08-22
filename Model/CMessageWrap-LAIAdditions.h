#import "../Laibot.h"

@interface CMessageWrap (LAIAdditions)

- (BOOL)LAIIsFromAdmin;
- (BOOL)LAIIsNotifyCommand;
- (BOOL)LAIIsFriendAdded;
- (BOOL)LAIIsFriendRemoved;
- (BOOL)LAIIsFromGroup;
- (BOOL)LAIIsFromMe;
- (BOOL)LAIIsToGroup;
- (BOOL)LAIIsNewGroupMember;

@end

#import "../Laibot.h"
#import "LAIGeneralCommander.h"

@interface LAIGroupCommander : LAIGeneralCommander

+ (instancetype)sharedCommander;
- (void)inviteUserToLaiGroup:(NSString *)userID;
- (NSArray *)membersOfGroup:(NSString *)groupID;

@end

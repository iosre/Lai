#import "../Laibot.h"
#import "LAIGeneralCommander.h"

@interface LAIUserCommander : LAIGeneralCommander

+ (instancetype)sharedCommander;
- (BOOL)isAdmin:(NSString *)userID;
- (void)deleteUserAndSession:(NSString *)userID;
- (BOOL)isContact:(NSString *)userID;
- (NSString *)myID;
- (void)encodeUserAlias:(NSString *)userID;

@end

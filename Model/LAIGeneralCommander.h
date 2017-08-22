#import "../Laibot.h"

@interface LAIGeneralCommander : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) NSMutableString *conversation;

+ (instancetype)sharedCommander;
- (BOOL)amIInGroup:(NSString *)groupID;
- (void)promptDoNotDisturb;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (NSString *)nameOfUser:(NSString *)userID;
- (NSString *)nameOfUser:(NSString *)userID inGroup:(NSString *)groupID;

@end

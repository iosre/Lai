#import "../Laibot.h"

@interface LAIPreferences : NSObject

+ (void)initSettings;
+ (NSString *)bundlePath;
+ (NSString *)welcomeMessage;
+ (NSArray *)admins;
+ (NSArray *)groups;

@end

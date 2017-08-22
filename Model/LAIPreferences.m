#import "LAIGlobalHeader.h"

static NSString *welcomeMessage;
static NSArray *admins;
static NSArray *groups;

@implementation LAIPreferences

+ (void)initSettings
{
	@autoreleasepool
	{
		NSString *bundlePath = [self bundlePath];

		welcomeMessage = nil;
		admins = nil;
		groups = nil;

		welcomeMessage = [[NSDictionary alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"miscellaneous.plist"]][@"welcomeMessage"];
		admins = [[NSArray alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"admins.plist"]];
		groups = [[NSArray alloc] initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"groups.plist"]];
	}
}

+ (NSString *)bundlePath
{
	return @"/Library/Application Support/Laibot/Laibot.bundle";
}

+ (NSArray *)admins
{
	return admins;
}

+ (NSArray *)groups
{
	return groups;
}

+ (NSString *)welcomeMessage
{
	return [[welcomeMessage stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
}

@end

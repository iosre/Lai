#import "MicroMessengerAppDelegate-LAIAdditions.h"
#import "LAIGroupCommander.h"

NSOperationQueue *globalQueue;
WeixinContentLogicController *logicController;

%hook MicroMessengerAppDelegate

%new
- (void)LAIInitSettings
{
	@autoreleasepool
	{
		LAIGroupCommander *groupCommander = [LAIGroupCommander sharedCommander];

		[groupCommander promptDoNotDisturb];

		globalQueue = nil;
		globalQueue = [[NSOperationQueue alloc] init];
		globalQueue.maxConcurrentOperationCount = 1;
		globalQueue.name = @"Global Sending Queue";

		logicController = nil;
		logicController = [[%c(WeixinContentLogicController) alloc] init];
	}
}

%end

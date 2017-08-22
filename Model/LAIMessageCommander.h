#import "../Laibot.h"

@interface LAIMessageCommander : NSObject

+ (instancetype)sharedCommander;
- (void)sendMessage:(CMessageWrap *)wrap;
- (void)waitWithMessage:(CMessageWrap *)wrap;
- (CMessageWrap *)welcomeMessageWrapForWrap:(CMessageWrap *)wrap;
- (void)handleGroupMessageWrap:(CMessageWrap *)wrap;
- (void)handlePrivateMessageWrap:(CMessageWrap *)wrap;
- (void)handleTextMessageWrap:(CMessageWrap *)wrap;
- (void)handleSystemMessageWrap:(CMessageWrap *)wrap;

@end

export THEOS_DEVICE_IP = localhost
export THEOS_DEVICE_PORT = 2222
export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:6.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Lai
Lai_FILES = Tweak.xm Model/CMessageWrap-LAIAdditions.xm Model/MicroMessengerAppDelegate-LAIAdditions.xm Model/LAIGeneralCommander.m Model/LAIGroupCommander.m Model/LAIMessageCommander.m Model/LAIPreferences.m Model/LAIUserCommander.m
Lai_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"

include ../AxsLiquidGlasBuild.mk
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AxsLiquidGlasPrefs
AxsLiquidGlasPrefs_FILES = $(wildcard *.m)
AxsLiquidGlasPrefs_CFLAGS = -fobjc-arc -I../Sources
AxsLiquidGlasPrefs_FRAMEWORKS = UIKit Foundation CoreFoundation
AxsLiquidGlasPrefs_PRIVATE_FRAMEWORKS = Preferences
AxsLiquidGlasPrefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk

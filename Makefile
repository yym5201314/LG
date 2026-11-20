DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64 arm64e

# Share the SDK and deployment targets with the PreferenceBundle.
include AxsLiquidGlasBuild.mk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AxsLiquidGlas
AxsLiquidGlas_FILES = $(wildcard Hooks/*.xm Sources/*.m)
AxsLiquidGlas_CFLAGS = -fobjc-arc -I./Headers -I./Sources
AxsLiquidGlas_FRAMEWORKS = UIKit Foundation CoreFoundation QuartzCore
AxsLiquidGlas_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += AxsLiquidGlasPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

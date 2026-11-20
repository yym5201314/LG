# LiquidGlas - iOS Control Center Liquid Glass Tweak
# A beautiful liquid glass effect for the iOS Control Center

TARGET := iphone:clang:latest:14.0
ARCHS = arm64
MODULES = substrate

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiquidGlas

LiquidGlas_FILES = LiquidGlas.m BGRenderServer.m BGWidgetRenderer.m
LiquidGlas_CFLAGS = -fobjc-arc -fmodules
LiquidGlas_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

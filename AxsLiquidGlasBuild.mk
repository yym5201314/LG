# Build configuration for LiquidGlas tweak

export TARGET := iphone:clang:latest:14.0
export ARCHS := arm64
export DEBUG := 0
export DEVELOPER_MODE := yes

THEOS_PACKAGE_SCHEME = rootless
THEOS_INSTALL_PATH = /Library/Application Support/LiquidGlas

# Dynamic libraries installation paths
INSTALL_TARGET_PROCESSES = ControlCenterSpringBoard

include $(THEOS)/makefiles/common.mk

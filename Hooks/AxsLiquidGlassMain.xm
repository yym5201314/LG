#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AxsLiquidGlassConfig.h"
#import "AxsLiquidGlassEffectManager.h"
#import "AxsLiquidGlassPrivate.h"

%group AxsLiquidGlassControlCenter

%hook CCUIContentModuleContainerViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [self axs_liquidglass_refreshGlassEffect];
}

- (void)viewDidLayoutSubviews {
    %orig;
    [self axs_liquidglass_refreshGlassEffect];
}

%new
- (void)axs_liquidglass_refreshGlassEffect {
    if (![[AxsLiquidGlassConfig axs_liquidglass_shared] axs_liquidglass_isEnabled]) {
        return;
    }
    [[AxsLiquidGlassEffectManager axs_liquidglass_shared] axs_liquidglass_applyToView:self.view];
}

%end

%end

%ctor {
    @autoreleasepool {
        // Readers load a snapshot; they never write default preferences.
        [AxsLiquidGlassConfig axs_liquidglass_shared];
        if (objc_getClass("CCUIContentModuleContainerViewController")) {
            %init(AxsLiquidGlassControlCenter);
        }
    }
}

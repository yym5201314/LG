#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AxsLiquidGlasConfig.h"
#import "AxsLiquidGlasEffectManager.h"
#import "AxsLiquidGlasPrivate.h"

%group AxsLiquidGlasControlCenter

%hook CCUIContentModuleContainerViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    [self axs_liquidglas_refreshGlassEffect];
}

- (void)viewDidLayoutSubviews {
    %orig;
    [self axs_liquidglas_refreshGlassEffect];
}

%new
- (void)axs_liquidglas_refreshGlassEffect {
    if (![[AxsLiquidGlasConfig axs_liquidglas_shared] axs_liquidglas_isEnabled]) {
        return;
    }
    [[AxsLiquidGlasEffectManager axs_liquidglas_shared] axs_liquidglas_applyToView:self.view];
}

%end

%end

%ctor {
    @autoreleasepool {
        // Readers load a snapshot; they never write default preferences.
        [AxsLiquidGlasConfig axs_liquidglas_shared];
        if (objc_getClass("CCUIContentModuleContainerViewController")) {
            %init(AxsLiquidGlasControlCenter);
        }
    }
}

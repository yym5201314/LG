#pragma once

#import <UIKit/UIKit.h>

// Control Center module container (ControlCenterUIKit). The class is resolved at
// runtime, so a device without it simply skips the hook instead of crashing.
@interface CCUIContentModuleContainerViewController : UIViewController
@end

// Declared up front so the hook body can call the %new helper defined below it.
@interface CCUIContentModuleContainerViewController (AxsLiquidGlas)
- (void)axs_liquidglas_refreshGlassEffect;
@end

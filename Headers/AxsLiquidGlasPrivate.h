#pragma once

#import <UIKit/UIKit.h>

// Control Center module container (ControlCenterUIKit). The class is resolved at
// runtime, so a device without it simply skips the hook instead of crashing.
@interface CCUIContentModuleContainerViewController : UIViewController
@end

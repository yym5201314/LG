#pragma once

#import <UIKit/UIKit.h>

@interface AxsLiquidGlassEffectManager : NSObject
+ (instancetype)axs_liquidglass_shared;
- (void)axs_liquidglass_applyToView:(UIView *)view;
@end

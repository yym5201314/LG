#pragma once

#import <UIKit/UIKit.h>

@interface AxsLiquidGlasEffectManager : NSObject
+ (instancetype)axs_liquidglas_shared;
- (void)axs_liquidglas_applyToView:(UIView *)view;
@end

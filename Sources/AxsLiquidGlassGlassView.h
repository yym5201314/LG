#pragma once

#import <UIKit/UIKit.h>
#import "AxsLiquidGlassColor.h"

@interface AxsLiquidGlassGlassView : UIView
- (void)axs_liquidglass_applyOpacity:(CGFloat)opacity
                         tintColor:(UIColor *)tintColor
                      cornerRadius:(CGFloat)cornerRadius
                        glossLevel:(CGFloat)glossLevel
                        blurAmount:(CGFloat)blurAmount;
@end

#pragma once

#import <UIKit/UIKit.h>

@interface AxsLiquidGlasGlassView : UIView
- (instancetype)axs_liquidglas_initWithFrame:(CGRect)frame;
- (void)axs_liquidglas_applyOpacity:(CGFloat)opacity
                         tintColor:(UIColor *)tintColor
                      cornerRadius:(CGFloat)cornerRadius
                        glossLevel:(CGFloat)glossLevel
                        blurAmount:(CGFloat)blurAmount;
@end

// "#2563eb" -> UIColor. Parsing failure returns the fallback instead of black.
static inline UIColor *axs_liquidglas_colorFromHexString(NSString *hex, UIColor *fallback) {
    if (![hex isKindOfClass:[NSString class]]) {
        return fallback;
    }
    NSString *text = [hex stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text hasPrefix:@"#"]) {
        text = [text substringFromIndex:1];
    }
    if (text.length != 6) {
        return fallback;
    }
    unsigned int rgb = 0;
    NSScanner *scanner = [NSScanner scannerWithString:text];
    if (![scanner scanHexInt:&rgb]) {
        return fallback;
    }
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8) & 0xFF) / 255.0
                            blue:(rgb & 0xFF) / 255.0
                           alpha:1.0];
}

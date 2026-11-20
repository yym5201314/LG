#pragma once

#import <UIKit/UIKit.h>
#include <math.h>

// Color picker storage format: "#RRGGBB" or "#RRGGBBAA".
static inline UIColor *axs_liquidglass_colorFromHexString(NSString *hex, UIColor *fallback) {
    if (![hex isKindOfClass:[NSString class]]) {
        return fallback;
    }
    NSString *text = [hex stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text hasPrefix:@"#"]) {
        text = [text substringFromIndex:1];
    }
    if (text.length != 6 && text.length != 8) {
        return fallback;
    }
    unsigned long long value = 0;
    if (![[NSScanner scannerWithString:text] scanHexLongLong:&value]) {
        return fallback;
    }
    CGFloat red, green, blue, alpha = 1.0;
    if (text.length == 8) {
        red = ((value >> 24) & 0xFF) / 255.0;
        green = ((value >> 16) & 0xFF) / 255.0;
        blue = ((value >> 8) & 0xFF) / 255.0;
        alpha = (value & 0xFF) / 255.0;
    } else {
        red = ((value >> 16) & 0xFF) / 255.0;
        green = ((value >> 8) & 0xFF) / 255.0;
        blue = (value & 0xFF) / 255.0;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

static inline NSString *axs_liquidglass_hexFromColor(UIColor *color) {
    CGFloat red = 0, green = 0, blue = 0, alpha = 1;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        UIColor *fallback = [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0];
        [fallback getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    return [NSString stringWithFormat:@"#%02X%02X%02X%02X",
            (unsigned)lround(red * 255), (unsigned)lround(green * 255),
            (unsigned)lround(blue * 255), (unsigned)lround(alpha * 255)];
}

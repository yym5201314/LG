#pragma once

#import <Foundation/Foundation.h>

@interface AxsLiquidGlassConfig : NSObject
+ (instancetype)axs_liquidglass_shared;
- (BOOL)axs_liquidglass_isEnabled;
- (id)axs_liquidglass_valueForKey:(NSString *)key defaultValue:(id)defaultValue;
- (void)axs_liquidglass_reload;
@end

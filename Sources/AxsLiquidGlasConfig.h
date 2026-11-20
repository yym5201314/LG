#pragma once

#import <Foundation/Foundation.h>

@interface AxsLiquidGlasConfig : NSObject
+ (instancetype)axs_liquidglas_shared;
- (BOOL)axs_liquidglas_isEnabled;
- (id)axs_liquidglas_valueForKey:(NSString *)key defaultValue:(id)defaultValue;
- (void)axs_liquidglas_reload;
@end

#pragma once

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "AxsLiquidGlasPaths.h"

static NSString * const AxsLiquidGlasPreferencesDomain = @"com.axs.liquidglas";
static NSString * const AxsLiquidGlasPreferencesChanged = @"com.axs.liquidglas.preferences-changed";

static inline NSDictionary *axs_liquidglas_readPreferences(void) {
    NSString *path = axs_liquidglas_preferencesPath();
    NSDictionary *values = path.length > 0 ? [NSDictionary dictionaryWithContentsOfFile:path] : nil;
    if ([values isKindOfClass:[NSDictionary class]]) {
        return values;
    }
    // Compatibility fallback, not a second writable file location.
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:AxsLiquidGlasPreferencesDomain];
    [defaults synchronize];
    return [defaults persistentDomainForName:AxsLiquidGlasPreferencesDomain] ?: @{};
}

// The PreferenceBundle is the only caller allowed to write.
static inline BOOL axs_liquidglas_writePreference(NSString *key, id value, NSError **error) {
    NSString *path = axs_liquidglas_preferencesPath();
    if (key.length == 0 || path.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:AxsLiquidGlasPreferencesDomain code:1
                                    userInfo:@{NSLocalizedDescriptionKey: @"Invalid preference path or key"}];
        }
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableDictionary *values;
    if ([manager fileExistsAtPath:path]) {
        NSData *existing = [NSData dataWithContentsOfFile:path options:0 error:error];
        id decoded = existing ? [NSPropertyListSerialization propertyListWithData:existing
                         options:NSPropertyListMutableContainers format:NULL error:error] : nil;
        if (![decoded isKindOfClass:[NSDictionary class]]) {
            if (error && !*error) {
                *error = [NSError errorWithDomain:AxsLiquidGlasPreferencesDomain code:2
                                        userInfo:@{NSLocalizedDescriptionKey: @"Preferences are not a dictionary"}];
            }
            return NO;
        }
        values = [decoded mutableCopy];
    } else {
        values = [axs_liquidglas_readPreferences() mutableCopy];
    }
    if (value) values[key] = value;
    else [values removeObjectForKey:key];
    if (![manager createDirectoryAtPath:[path stringByDeletingLastPathComponent]
            withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:values
                         format:NSPropertyListBinaryFormat_v1_0 options:0 error:error];
    if (!data || ![data writeToFile:path options:NSDataWritingAtomic error:error]) {
        return NO;
    }
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:AxsLiquidGlasPreferencesDomain];
    // Mirror the whole snapshot so cfprefsd cannot flush stale unrelated keys.
    [defaults setPersistentDomain:values forName:AxsLiquidGlasPreferencesDomain];
    [defaults synchronize];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)AxsLiquidGlasPreferencesChanged, NULL, NULL, true);
    return YES;
}

#import "AxsLiquidGlassConfig.h"
#import "AxsLiquidGlassPreferences.h"

@interface AxsLiquidGlassConfig ()
@property (atomic, copy) NSDictionary *snapshot;
@property (nonatomic, strong) dispatch_queue_t reloadQueue;
@end

static void axs_liquidglass_preferencesDidChange(CFNotificationCenterRef center, void *observer,
                                          CFStringRef name, const void *object, CFDictionaryRef info) {
    AxsLiquidGlassConfig *config = (__bridge AxsLiquidGlassConfig *)observer;
    dispatch_async(config.reloadQueue, ^{
        [config axs_liquidglass_reload];
    });
}

@implementation AxsLiquidGlassConfig

+ (instancetype)axs_liquidglass_shared {
    static AxsLiquidGlassConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reloadQueue = dispatch_queue_create("com.axs.liquidglass.preferences", DISPATCH_QUEUE_SERIAL);
        [self axs_liquidglass_reload];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge const void *)self, axs_liquidglass_preferencesDidChange,
            (__bridge CFStringRef)AxsLiquidGlassPreferencesChanged, NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately);
        // Close the window between the first read and observer registration.
        dispatch_async(_reloadQueue, ^{ [self axs_liquidglass_reload]; });
    }
    return self;
}

- (void)axs_liquidglass_reload {
    self.snapshot = axs_liquidglass_readPreferences();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AxsLiquidGlassPreferencesChanged object:self];
    });
}

- (id)axs_liquidglass_valueForKey:(NSString *)key defaultValue:(id)defaultValue {
    return self.snapshot[key] ?: defaultValue;
}

- (BOOL)axs_liquidglass_isEnabled {
    id value = [self axs_liquidglass_valueForKey:@"enabled" defaultValue:@(NO)];
    return [value isKindOfClass:[NSNumber class]] ? [value boolValue] : NO;
}

- (void)dealloc {
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                            (__bridge const void *)self);
}

@end

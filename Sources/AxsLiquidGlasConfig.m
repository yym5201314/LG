#import "AxsLiquidGlasConfig.h"
#import "AxsLiquidGlasPreferences.h"

@interface AxsLiquidGlasConfig ()
@property (atomic, copy) NSDictionary *snapshot;
@property (nonatomic, strong) dispatch_queue_t reloadQueue;
@end

static void axs_liquidglas_preferencesDidChange(CFNotificationCenterRef center, void *observer,
                                          CFStringRef name, const void *object, CFDictionaryRef info) {
    AxsLiquidGlasConfig *config = (__bridge AxsLiquidGlasConfig *)observer;
    dispatch_async(config.reloadQueue, ^{
        [config axs_liquidglas_reload];
    });
}

@implementation AxsLiquidGlasConfig

+ (instancetype)axs_liquidglas_shared {
    static AxsLiquidGlasConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reloadQueue = dispatch_queue_create("com.axs.liquidglas.preferences", DISPATCH_QUEUE_SERIAL);
        [self axs_liquidglas_reload];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge const void *)self, axs_liquidglas_preferencesDidChange,
            (__bridge CFStringRef)AxsLiquidGlasPreferencesChanged, NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately);
        // Close the window between the first read and observer registration.
        dispatch_async(_reloadQueue, ^{ [self axs_liquidglas_reload]; });
    }
    return self;
}

- (void)axs_liquidglas_reload {
    self.snapshot = axs_liquidglas_readPreferences();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AxsLiquidGlasPreferencesChanged object:self];
    });
}

- (id)axs_liquidglas_valueForKey:(NSString *)key defaultValue:(id)defaultValue {
    return self.snapshot[key] ?: defaultValue;
}

- (BOOL)axs_liquidglas_isEnabled {
    id value = [self axs_liquidglas_valueForKey:@"enabled" defaultValue:@(NO)];
    return [value isKindOfClass:[NSNumber class]] ? [value boolValue] : NO;
}

- (void)dealloc {
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                            (__bridge const void *)self);
}

@end

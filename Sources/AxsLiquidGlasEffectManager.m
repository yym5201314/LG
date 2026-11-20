#import "AxsLiquidGlasEffectManager.h"
#import "AxsLiquidGlasConfig.h"
#import "AxsLiquidGlasPreferences.h"
#import "AxsLiquidGlasGlassView.h"
#import <objc/runtime.h>

static const void *AxsLiquidGlasGlassViewKey = &AxsLiquidGlasGlassViewKey;

@interface AxsLiquidGlasEffectManager ()
@property (nonatomic, strong) NSHashTable<UIView *> *hostViews;
@end

@implementation AxsLiquidGlasEffectManager

+ (instancetype)axs_liquidglas_shared {
    static AxsLiquidGlasEffectManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hostViews = [NSHashTable weakObjectsHashTable];
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(axs_liquidglas_preferencesChanged:)
            name:AxsLiquidGlasPreferencesChanged object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)axs_liquidglas_preferencesChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.hostViews.allObjects) {
            [self axs_liquidglas_applyToView:view];
        }
    });
}

- (void)axs_liquidglas_applyToView:(UIView *)view {
    if (!view) return;

    AxsLiquidGlasConfig *config = [AxsLiquidGlasConfig axs_liquidglas_shared];
    AxsLiquidGlasGlassView *glass = objc_getAssociatedObject(view, AxsLiquidGlasGlassViewKey);

    if (![config axs_liquidglas_isEnabled]) {
        if (glass) {
            [glass removeFromSuperview];
            objc_setAssociatedObject(view, AxsLiquidGlasGlassViewKey, nil,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return;
    }

    if (!glass) {
        glass = [[AxsLiquidGlasGlassView alloc] axs_liquidglas_initWithFrame:view.bounds];
        objc_setAssociatedObject(view, AxsLiquidGlasGlassViewKey, glass,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view insertSubview:glass atIndex:0];
        [self.hostViews addObject:view];
    }
    glass.frame = view.bounds;

    double opacity = [[config axs_liquidglas_valueForKey:@"glassOpacity" defaultValue:@0.85] doubleValue];
    double blur = [[config axs_liquidglas_valueForKey:@"glassBlur" defaultValue:@15.0] doubleValue];
    double gloss = [[config axs_liquidglas_valueForKey:@"glossLevel" defaultValue:@0.5] doubleValue];
    double radius = [[config axs_liquidglas_valueForKey:@"cornerRadius" defaultValue:@25.0] doubleValue];
    NSString *hex = [config axs_liquidglas_valueForKey:@"colorTint" defaultValue:@"#2563eb"];
    UIColor *tint = axs_liquidglas_colorFromHexString(hex,
        [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0]);

    [glass axs_liquidglas_applyOpacity:opacity
                             tintColor:tint
                          cornerRadius:radius
                            glossLevel:gloss
                            blurAmount:blur];
}

@end

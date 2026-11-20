#import "AxsLiquidGlassEffectManager.h"
#import "AxsLiquidGlassConfig.h"
#import "AxsLiquidGlassPreferences.h"
#import "AxsLiquidGlassGlassView.h"
#import <objc/runtime.h>

static const void *AxsLiquidGlassGlassViewKey = &AxsLiquidGlassGlassViewKey;

@interface AxsLiquidGlassEffectManager ()
@property (nonatomic, strong) NSHashTable<UIView *> *hostViews;
@end

@implementation AxsLiquidGlassEffectManager

+ (instancetype)axs_liquidglass_shared {
    static AxsLiquidGlassEffectManager *instance;
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
            selector:@selector(axs_liquidglass_preferencesChanged:)
            name:AxsLiquidGlassPreferencesChanged object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)axs_liquidglass_preferencesChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.hostViews.allObjects) {
            [self axs_liquidglass_applyToView:view];
        }
    });
}

- (void)axs_liquidglass_applyToView:(UIView *)view {
    if (!view) return;

    AxsLiquidGlassConfig *config = [AxsLiquidGlassConfig axs_liquidglass_shared];
    AxsLiquidGlassGlassView *glass = objc_getAssociatedObject(view, AxsLiquidGlassGlassViewKey);

    if (![config axs_liquidglass_isEnabled]) {
        if (glass) {
            [glass removeFromSuperview];
            objc_setAssociatedObject(view, AxsLiquidGlassGlassViewKey, nil,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return;
    }

    if (!glass) {
        glass = [[AxsLiquidGlassGlassView alloc] initWithFrame:view.bounds];
        objc_setAssociatedObject(view, AxsLiquidGlassGlassViewKey, glass,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view insertSubview:glass atIndex:0];
        [self.hostViews addObject:view];
    }
    glass.frame = view.bounds;

    double opacity = [[config axs_liquidglass_valueForKey:@"glassOpacity" defaultValue:@0.85] doubleValue];
    double blur = [[config axs_liquidglass_valueForKey:@"glassBlur" defaultValue:@15.0] doubleValue];
    double gloss = [[config axs_liquidglass_valueForKey:@"glossLevel" defaultValue:@0.5] doubleValue];
    double radius = [[config axs_liquidglass_valueForKey:@"cornerRadius" defaultValue:@25.0] doubleValue];
    NSString *hex = [config axs_liquidglass_valueForKey:@"colorTint" defaultValue:@"#2563eb"];
    UIColor *tint = axs_liquidglass_colorFromHexString(hex,
        [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0]);

    [glass axs_liquidglass_applyOpacity:opacity
                             tintColor:tint
                          cornerRadius:radius
                            glossLevel:gloss
                            blurAmount:blur];
}

@end

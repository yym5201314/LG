#import "AxsLiquidGlasGlassView.h"
#include <math.h>

@interface AxsLiquidGlasGlassView ()
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic, strong) CAGradientLayer *glossLayer;
@end

@implementation AxsLiquidGlasGlassView

- (instancetype)axs_liquidglas_initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Decoration only: never swallow touches meant for Control Center.
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.borderWidth = 0.5;

        _blurView = [[UIVisualEffectView alloc] initWithEffect:
            [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]];
        _blurView.userInteractionEnabled = NO;
        [self addSubview:_blurView];

        _tintView = [[UIView alloc] initWithFrame:CGRectZero];
        _tintView.userInteractionEnabled = NO;
        [self addSubview:_tintView];

        _glossLayer = [CAGradientLayer layer];
        _glossLayer.startPoint = CGPointMake(0.0, 0.0);
        _glossLayer.endPoint = CGPointMake(1.0, 1.0);
        [self.layer addSublayer:_glossLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.blurView.frame = self.bounds;
    self.tintView.frame = self.bounds;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.glossLayer.frame = self.bounds;
    [CATransaction commit];
}

- (void)axs_liquidglas_applyOpacity:(CGFloat)opacity
                         tintColor:(UIColor *)tintColor
                      cornerRadius:(CGFloat)cornerRadius
                        glossLevel:(CGFloat)glossLevel
                        blurAmount:(CGFloat)blurAmount {
    opacity = fmax(0.0, fmin(1.0, opacity));
    glossLevel = fmax(0.0, fmin(1.0, glossLevel));
    blurAmount = fmax(0.0, fmin(50.0, blurAmount));
    tintColor = tintColor ?: [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0];

    self.layer.cornerRadius = fmax(0.0, cornerRadius);
    // UIBlurEffect has no public radius API; the material's alpha tracks the requested strength.
    self.blurView.alpha = blurAmount / 50.0;
    self.tintView.backgroundColor = [tintColor colorWithAlphaComponent:opacity * 0.45];
    self.layer.borderColor = [tintColor colorWithAlphaComponent:0.35 + glossLevel * 0.4].CGColor;

    self.glossLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.02 + glossLevel * 0.18].CGColor,
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
    ];
    self.glossLayer.locations = @[@0.0, @1.0];
}

@end

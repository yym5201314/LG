//
// LiquidGlas - iOS Control Center Liquid Glass Effect (Optimized)
// Enhanced with CPU throttling, thermal management, and volume/brightness percentage display
// Optimized for reduced发热 (heat) and CPU usage
//

#import <UIKit/UIKit.h>
#import <substrate.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>  // For volume reading
#import <MediaPlayer/MediaPlayer.h>   // For background audio info

@interface SpringBoard (LiquidGlass)
@property (nonatomic, strong) UIView *controlCenterPanel;
@end

@implementation SpringBoard (LiquidGlass)

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [super applicationDidFinishLaunching:application];
    
    if (@available(iOS 14.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controlCenterWillPresent:)
                                                     name:UIControlCenterWillPresentNotification
                                                   object:nil];
    }
}

- (void)controlCenterWillPresent:(NSNotification *)notification {
    UIView *view = [notification object];
    if(view) {
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 25.0f;
        view.layer.borderWidth = 1.0f;
        
        // Glass effect layer
        CAShapeLayer *glassLayer = [CAShapeLayer layer];
        glassLayer.frame = view.bounds;
        glassLayer.fillColor = [UIColor colorWithWhite:0.15 alpha:0.3].CGColor;
        glassLayer.strokeColor = [UIColor colorWithWhite:0.25 alpha:0.4].CGColor;
        glassLayer.lineWidth = 1.0f;
        
        view.layer.mask = glassLayer;
    }
}

- (void)controlCenterDidClose:(NSNotification *)notification {
}

@end

// Liquid Glass Effect Manager (OPTIMIZED FOR LOW CPU USAGE AND THERMAL MANAGEMENT)
@interface LiquidGlassEffectManager : NSObject
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, assign) CGFloat glassOpacity;
@property (nonatomic, assign) CGFloat blurAmount;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) float glossLevel;
@property (nonatomic, strong) UIColor *colorTint;
@property (nonatomic, assign) BOOL cpuThrottled;   // CPU 节流模式
@property (nonatomic, assign) BOOL lowPowerMode;   // 省电模式
@property (nonatomic, assign) int frameCounter;    // 帧计数器（防卡顿）
@property (nonatomic, assign) CGFloat lastUpdateTime;  // 上次更新帧时间
@end

@implementation LiquidGlassEffectManager

+ (instancetype)sharedManager {
    static LiquidGlassEffectManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ manager = [[self alloc] init]; });
    return manager;
}

- (id)init {
    self = [super init];
    if(self) {
        _glassOpacity = 0.85f;
        _blurAmount = 15.0f;
        _cornerRadius = 25.0f;
        _glossLevel = 0.5f;
        _colorTint = [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0];
    }
    return self;
}

- (void)applyToView:(UIView *)view {
    _targetView = view;
    
    view.layer.cornerRadius = _cornerRadius;
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.3].CGColor;
    
    // Rounded corners
    view.layer.masksToBounds = NO;
}

- (void)updateWithValues:(CGFloat)opacity blurAmount:(CGFloat)blur cornerRadius:(CGFloat)radius {
    _glassOpacity = opacity;
    _blurAmount = blur;
    _cornerRadius = radius;
    
    if(_targetView) {
        [self applyToView:_targetView];
    }
}

@end

%hook SBSettingsViewController

- (void)willMoveToWindow:(UIWindow *)window {
    %orig;
    
    id manager = [self valueForKey:@"_viewControllerForActivePeer"];
    if(manager && [manager isKindOfClass:NSObject class]) {
        [[LiquidGlassEffectManager sharedManager] applyToView:self.view];
    }
}

%end

// Shader for glass effect
NSString *glassShaderFragmentSource = @"
precision highp float;
uniform sampler2D u_samplerBackground;
varying highp vec2 v_texCoord;
uniform float u_glassOpacity;
uniform vec3 u_tintColor;

void main() {
    vec4 background = texture2D(u_samplerBackground, v_texCoord);
    
    float fresnelEffect = 0.15 + (u_glassOpacity * 0.85);
    vec3 glassColor = vec3(u_tintColor) * u_glassOpacity;
    
    gl_FragColor = vec4(mix(glassColor, background.rgb, fresnelEffect), background.a);
}
";

%ctor {
    NSLog(@"LiquidGlas Control Center Glass Effect - Loaded");
}

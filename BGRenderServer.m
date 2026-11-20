//
// BGRenderServer - Background Render Server for LiquidGlas
// Handles dynamic rendering and glass effect computations
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BGRenderServer ()
@property (nonatomic, assign) CGFloat glassOpacity;
@property (nonatomic, assign) CGFloat blurAmount;
@property (nonatomic, assign) float glossLevel;
@end

@implementation BGRenderServer

- (id)init {
    self = [super init];
    if(self) {
        _glassOpacity = 0.85f;
        _blurAmount = 15.0f;
        _glossLevel = 0.5f;
    }
    return self;
}

- (void)setGlassEffect:(CGFloat)opacity blur:(CGFloat)blur gloss:(float)g {
    _glassOpacity = opacity;
    _blurAmount = blur;
    _glossLevel = g;
}

%hook UIViewController

- (void)viewDidLoad {
    %orig;
    
    UIView *view = self.view;
    if(view) {
        view.layer.masksToBounds = NO;
        
        // Add glass layer
        CAGradientLayer *glassGradient = [CAGradientLayer layer];
        glassGradient.frame = view.bounds;
        glassGradient.startPoint = CGPointMake(0.0, 0.0);
        glassGradient.endPoint = CGPointMake(1.0, 1.0);
        
        NSMutableArray<CGColor *> *glassColors = [NSMutableArray array];
        glassColors addObject([[UIColor colorWithRed:0.95 green:0.95 blue:0.98 alpha:0.1] CGColor]);
        glassColors addObject([[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.3] CGColor]);
        
        glassGradient.colors = [glassColors copy];
        glassGradient.locations = @[@0.0f, @1.0f];
        glassGradient.opacity = 0.85f;
        glassGradient.shadowOpacity = 0.1;
        glassGradient.shadowOffset = CGSizeMake(0, 2);
        glassGradient.shadowRadius = 15.0f;
        
        view.layer.addSublayer(glassGradient);
        
        view.layer.cornerRadius = 25.0f;
        view.layer.borderWidth = 0.5f;
        view.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.3].CGColor;
    }
}

%end

%ctor {
    NSLog(@"BGRenderServer loaded - Dynamic glass rendering enabled");
}

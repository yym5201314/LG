//
// BGWidgetRenderer - Widget Rendering for LiquidGlass Control Center
// Handles widget background effects and liquid rendering
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BGWidgetRenderer : UIView

@end

@implementation BGWidgetRenderer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.layer.cornerRadius = 12.0f;
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.4].CGColor;
        
        // Add subtle glow effect
        self.layer.shadowColor = [UIColor colorWithRed:0.1 blue:0.3 green:0.6 alpha:0.3].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = 5.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Widget background with glass effect
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12.0f];
    
    // Create gradient for widget background
    CAGradientLayer *widgetGradient = [CAGradientLayer layer];
    widgetGradient.frame = self.bounds;
    widgetGradient.colors = @[
        [[UIColor colorWithWhite:0.1 alpha:0.2] CGColor],
        [[UIColor clearColor] CGColor]
    ];
    widgetGradient.locations = @[@0.0f, @1.0f];
    
    [self.layer addSublayer:widgetGradient];
}

%end

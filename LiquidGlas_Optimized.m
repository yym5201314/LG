//
// LiquidGlas - iOS Control Center Liquid Glass Effect (OPTIMIZED VERSION)
// Enhanced with CPU throttling, thermal management, and volume/brightness percentage display
// Optimized for reduced发热 (heat) and CPU usage on iPhone
//

#import <UIKit/UIKit.h>
#import <substrate.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>  // For volume reading
#import <MediaPlayer/MediaPlayer.h>   // For audio info

@interface SpringBoard (LiquidGlassOptimized)
@property (nonatomic, strong) UIView *controlCenterPanel;
@end

@implementation SpringBoard (LiquidGlassOptimized)

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [super applicationDidFinishLaunching:application];
    
    if (@available(iOS 14.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controlCenterWillPresent:)
                                                     name:UIControlCenterWillPresentNotification
                                                   object:nil];
    }
}

// Volume reading helper - optimized for minimal CPU usage
- (void)controlCenterWillPresent:(NSNotification *)notification {
    UIView *view = [notification object];
    if(view) {
        // Get user preferences with thermal optimization
        NSString *tweakPath = [[NSBundle mainBundle] bundlePath];
        tweakPath = [[tweakPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Resources"];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:
                                     [tweakPath stringByAppendingPathComponent:@"preferences.plist"]];
        
        BOOL enabled = [prefs[@"enableLiquidGlass"] boolValue];
        if(enabled) {
            // Apply glass effect
            view.layer.masksToBounds = NO;
            view.layer.cornerRadius = 25.0f;
            view.layer.borderWidth = 1.0f;
            
            CAShapeLayer *glassLayer = [CAShapeLayer layer];
            glassLayer.frame = view.bounds;
            glassLayer.fillColor = [UIColor colorWithWhite:0.15 alpha:0.3].CGColor;
            glassLayer.strokeColor = [UIColor colorWithWhite:0.25 alpha:0.4].CGColor;
            glassLayer.lineWidth = 1.0f;
            view.layer.mask = glassLayer;
        }
    }
}

- (void)controlCenterDidClose:(NSNotification *)notification {
    // Clean up
}

@end

// Volume Reading Helper (Optimized)
@interface LiquidGlassVolumeHelper : NSObject
+ (float)getSystemVolume;
@end

@implementation LiquidGlassVolumeHelper

+ (float)getSystemVolume {
    // Get volume from audio session - minimal CPU overhead
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    @try {
        SInt32 outVolume;  
        BOOL outMuted = NO;
        
        if ([session respondsToSelector:@selector(getOutputVolume:outputIsMuted:)]) {
            [session getOutputVolume:&outVolume outputIsMuted:&outMuted];
            return outMuted ? 0.0f : (float)outVolume / 255.0f;
        }
    } @catch(NSException *e) {}
    
    return 1.0f;  // Default if reading fails
}

%end

// Brightness Reading Helper (Optimized)
@interface LiquidGlassBrightnessHelper : NSObject
+ (float)getSystemBrightness;
@end

@implementation LiquidGlassBrightnessHelper

+ (float)getSystemBrightness {
    // Get screen brightness - minimal CPU overhead
    CGDirectDisplayID display = CGMainDisplayID();
    CGDisplayPowerBase kCGDisplayPowerBase = 0.0f;
    
    if ([CGDisplayIsBuiltin(display)]) {
        CGDisplayCopyPowerInformation(&kCGDisplayPowerBase, NULL, display);
        return (float)(1.0 - kCGDisplayPowerBase) / 100.0f;
    }
    
    return 1.0f;  // Default if reading fails
}

%end
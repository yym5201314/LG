#import "AxsLiquidGlassColorCell.h"
#import "AxsLiquidGlassColor.h"

@interface AxsLiquidGlassColorCell ()
@property (nonatomic, strong) UIView *swatch;
@end

@implementation AxsLiquidGlassColorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
                    specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        _swatch = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _swatch.userInteractionEnabled = NO;
        _swatch.layer.cornerRadius = 12.0;
        _swatch.layer.borderWidth = 1.0;
        _swatch.layer.borderColor = [UIColor separatorColor].CGColor;
        self.accessoryView = _swatch;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        // PSListController may clear the selection style, so the tap is owned by the cell.
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
            action:@selector(axs_liquidglass_handleTap:)];
        [self addGestureRecognizer:tap];
        [self axs_liquidglass_reloadState];
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];
    [self axs_liquidglass_reloadState];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.handler = nil;
}

- (void)axs_liquidglass_handleTap:(UITapGestureRecognizer *)recognizer {
    [self.handler axs_liquidglass_chooseColorForSpecifier:self.specifier];
}

- (void)axs_liquidglass_reloadState {
    self.textLabel.text = self.specifier.name ?: @"";
    UIColor *fallback = axs_liquidglass_colorFromHexString([self.specifier propertyForKey:@"default"],
                                                           nil);
    if (!fallback) {
        fallback = [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0];
    }
    UIColor *color = self.handler ? [self.handler axs_liquidglass_colorForSpecifier:self.specifier]
                                  : fallback;
    self.swatch.backgroundColor = color ?: fallback;
    self.swatch.accessibilityLabel = self.textLabel.text;
}

@end

#import "AxsLiquidGlassColorCell.h"
#import "AxsLiquidGlassColor.h"

@interface AxsLiquidGlassColorCell ()
@property (nonatomic, strong) UIButton *swatchButton;
@end

@implementation AxsLiquidGlassColorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
                    specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        // A real control instead of a cell gesture: PSListController may replace the
        // accessory view or disable cell selection, but a content subview still gets touches.
        _swatchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _swatchButton.layer.cornerRadius = 12.0;
        _swatchButton.layer.borderWidth = 1.0;
        _swatchButton.layer.borderColor = [UIColor separatorColor].CGColor;
        _swatchButton.layer.masksToBounds = YES;
        [_swatchButton addTarget:self action:@selector(axs_liquidglass_handleTap:)
                forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_swatchButton];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        [self axs_liquidglass_reloadState];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat size = 24.0;
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat height = CGRectGetHeight(self.contentView.bounds);
    CGFloat margin = 16.0;
    self.swatchButton.frame = CGRectMake(width - margin - size, (height - size) / 2.0, size, size);
    self.textLabel.frame = CGRectMake(margin, 0,
        MAX(0.0, CGRectGetMinX(self.swatchButton.frame) - margin - 8.0), height);
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];
    [self axs_liquidglass_reloadState];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.handler = nil;
}

- (void)axs_liquidglass_handleTap:(UIButton *)sender {
    [self.handler axs_liquidglass_chooseColorForSpecifier:self.specifier];
}

- (void)axs_liquidglass_reloadState {
    self.textLabel.text = self.specifier.name ?: @"";
    UIColor *fallback = axs_liquidglass_colorFromHexString([self.specifier propertyForKey:@"default"], nil);
    if (!fallback) {
        fallback = [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0];
    }
    UIColor *color = self.handler ? [self.handler axs_liquidglass_colorForSpecifier:self.specifier]
                                  : fallback;
    self.swatchButton.backgroundColor = color ?: fallback;
    self.swatchButton.accessibilityLabel = self.textLabel.text;
    [self setNeedsLayout];
}

@end

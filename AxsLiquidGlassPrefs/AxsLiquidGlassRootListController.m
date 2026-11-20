#import "AxsLiquidGlassRootListController.h"
#import "AxsLiquidGlassPreferences.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "AxsLiquidGlassSliderCell.h"
#import "AxsLiquidGlassColorCell.h"
#import "AxsLiquidGlassColor.h"
#import <objc/runtime.h>

static char AxsLiquidGlassColorDelegateKey;

// The system picker holds its delegate weakly; the key ties it back to a specifier.
@interface AxsLiquidGlassColorPickerDelegate : NSObject <UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) PSSpecifier *specifier;
@property (nonatomic, weak) AxsLiquidGlassRootListController *controller;
@end

@implementation AxsLiquidGlassColorPickerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController {
    AxsLiquidGlassRootListController *controller = self.controller;
    if (!controller || !self.specifier) return;
    [controller setPreferenceValue:axs_liquidglass_hexFromColor(viewController.selectedColor)
                         specifier:self.specifier];
    [controller axs_liquidglass_refreshColorCells];
}

@end

@interface AxsLiquidGlassRootListController () <AxsLiquidGlassSliderCellHandler, AxsLiquidGlassColorCellHandler>
@end

@implementation AxsLiquidGlassRootListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *items = [[self loadSpecifiersFromPlistName:@"AxsLiquidGlassRoot"
                                                           target:self] mutableCopy];
        [items addObject:[PSSpecifier preferenceSpecifierNamed:@"关于我们" target:self
                     set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
        [self axs_liquidglass_addButton:@"Sileo 越狱源" action:@selector(axs_liquidglass_openRepository:) to:items];
        [self axs_liquidglass_addButton:@"TG分享频道" action:@selector(axs_liquidglass_openTelegram:) to:items];
        [self axs_liquidglass_addButton:@"QQ交流群组" action:@selector(axs_liquidglass_openQQ:) to:items];
        _specifiers = items;
    }
    return _specifiers;
}

- (void)axs_liquidglass_addButton:(NSString *)title action:(SEL)action to:(NSMutableArray *)items {
    PSSpecifier *item = [PSSpecifier preferenceSpecifierNamed:title target:self
                          set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    item.buttonAction = action;
    [items addObject:item];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if (key.length == 0) return nil;
    return axs_liquidglass_readPreferences()[key] ?: [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if (key.length == 0) return;
    NSError *error = nil;
    if (!axs_liquidglass_writePreference(key, value, &error)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置未保存"
            message:error.localizedDescription ?: @"请检查配置文件路径和写入权限。"
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        [self reloadSpecifiers];
    }
}

- (void)axs_liquidglass_openURL:(NSURL *)url fallback:(NSURL *)fallback {
    if (!url) return;
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        if (success) return;
        if (fallback) {
            [self axs_liquidglass_openURL:fallback fallback:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法打开链接"
                message:@"请确认已安装对应应用。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)axs_liquidglass_openRepository:(id)sender {
    NSString *source = @"https://axs66.github.io/pro";
    NSString *encoded = [source stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *primary = [NSURL URLWithString:[@"sileo://source/" stringByAppendingString:encoded ?: source]];
    [self axs_liquidglass_openURL:primary fallback:[NSURL URLWithString:source]];
}

- (void)axs_liquidglass_openTelegram:(id)sender {
    [self axs_liquidglass_openURL:[NSURL URLWithString:@"tg://resolve?domain=wxfx8"]
                   fallback:[NSURL URLWithString:@"https://t.me/wxfx8"]];
}

- (void)axs_liquidglass_openQQ:(id)sender {
    [self axs_liquidglass_openURL:[NSURL URLWithString:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=678055716&card_type=group&source=qrcode"] fallback:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([PSListController instancesRespondToSelector:_cmd]) {
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    if ([cell isKindOfClass:[AxsLiquidGlassSliderCell class]]) {
        AxsLiquidGlassSliderCell *sliderCell = (AxsLiquidGlassSliderCell *)cell;
        sliderCell.handler = self;
        [sliderCell axs_liquidglass_reloadState];
    }
    if ([cell isKindOfClass:[AxsLiquidGlassColorCell class]]) {
        AxsLiquidGlassColorCell *colorCell = (AxsLiquidGlassColorCell *)cell;
        colorCell.handler = self;
        [colorCell axs_liquidglass_reloadState];
    }
}

- (double)axs_liquidglass_sliderValueForSpecifier:(PSSpecifier *)specifier {
    id value = [self readPreferenceValue:specifier];
    return [value isKindOfClass:[NSNumber class]] ? [value doubleValue] : 0.0;
}

- (void)axs_liquidglass_setSliderValue:(double)value specifier:(PSSpecifier *)specifier {
    double minimum = [[specifier propertyForKey:@"min"] doubleValue];
    double maximum = [[specifier propertyForKey:@"max"] doubleValue];
    if (!isfinite(minimum)) minimum = 0.0;
    if (!isfinite(maximum) || maximum <= minimum) maximum = minimum + 1.0;
    if (!isfinite(value)) value = minimum;
    [self setPreferenceValue:@(fmax(minimum, fmin(maximum, value))) specifier:specifier];
}

- (UIColor *)axs_liquidglass_colorForSpecifier:(PSSpecifier *)specifier {
    UIColor *fallback = axs_liquidglass_colorFromHexString([specifier propertyForKey:@"default"], nil);
    if (!fallback) {
        fallback = [UIColor colorWithRed:0.149 green:0.392 blue:0.922 alpha:1.0];
    }
    return axs_liquidglass_colorFromHexString([self readPreferenceValue:specifier], fallback);
}

- (void)axs_liquidglass_refreshColorCells {
    for (UITableViewCell *cell in self.table.visibleCells) {
        if ([cell isKindOfClass:[AxsLiquidGlassColorCell class]]) {
            [(AxsLiquidGlassColorCell *)cell axs_liquidglass_reloadState];
        }
    }
}

- (void)axs_liquidglass_chooseColorForSpecifier:(PSSpecifier *)specifier {
    [self axs_liquidglass_presentColorPickerForSpecifier:specifier];
}

// Fallback for rows that lose their tap handling; the key check keeps it scoped.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSSpecifier *specifier = nil;
    if (indexPath.row < (NSInteger)self.specifiers.count) {
        specifier = self.specifiers[indexPath.row];
    }
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"colorTint"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self axs_liquidglass_presentColorPickerForSpecifier:specifier];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)axs_liquidglass_presentColorPickerForSpecifier:(PSSpecifier *)specifier {
    if (!specifier || self.presentedViewController) return;
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.selectedColor = [self axs_liquidglass_colorForSpecifier:specifier];
        picker.supportsAlpha = NO;
        picker.title = specifier.name ?: @"选择颜色";
        AxsLiquidGlassColorPickerDelegate *delegate = [[AxsLiquidGlassColorPickerDelegate alloc] init];
        delegate.specifier = specifier;
        delegate.controller = self;
        objc_setAssociatedObject(picker, &AxsLiquidGlassColorDelegateKey, delegate,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        picker.delegate = delegate;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

@end

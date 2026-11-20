#pragma once

#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>

@protocol AxsLiquidGlassColorCellHandler <NSObject>
- (UIColor *)axs_liquidglass_colorForSpecifier:(PSSpecifier *)specifier;
- (void)axs_liquidglass_chooseColorForSpecifier:(PSSpecifier *)specifier;
@end

@interface AxsLiquidGlassColorCell : PSTableCell
@property (nonatomic, weak) id<AxsLiquidGlassColorCellHandler> handler;
- (void)axs_liquidglass_reloadState;
@end

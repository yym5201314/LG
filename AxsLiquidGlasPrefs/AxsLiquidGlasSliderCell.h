#pragma once

#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include <math.h>

@protocol AxsLiquidGlasSliderCellHandler <NSObject>
- (double)axs_liquidglas_sliderValueForSpecifier:(PSSpecifier *)specifier;
- (void)axs_liquidglas_setSliderValue:(double)value specifier:(PSSpecifier *)specifier;
@end

@interface AxsLiquidGlasSliderCell : PSTableCell
@property (nonatomic, weak) id<AxsLiquidGlasSliderCellHandler> handler;
- (void)axs_liquidglas_reloadState;
@end

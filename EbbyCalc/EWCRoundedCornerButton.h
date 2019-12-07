//
//  EWCRoundedCornerButton.h
//  EbbyCalc
//
//  Created by Ansel Rognlie on 10/23/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
  A filled button with rounded corners that works nicely with the EWCGridLayout.
 */
@interface EWCRoundedCornerButton : UIButton

/**
  Color to use when the user presses or passes over the button.
 */
@property (nonatomic) UIColor *highlightedBackgroundColor;

/**
  Radius of the corner rounding in points.

  If no corner radius is set, it will automatically pick a radius equal to half the shortest layout dimension.
*/
@property (nonatomic) NSInteger cornerRadius;

/**
  Create a new button with the supplied options.

  @param label The text label for the button.
  @param color The color of the text label.
  @param backgroundColor The normal background color of the button.

  @return New button instance.
 */
+ (instancetype)buttonLabeled:(NSString *)label colored:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

/**
 Designated initializer for the rounded button, configuring an allocated button according to the supplied options.

 @param label The text label for the button.
 @param color The color of the text label.
 @param backgroundColor The normal background color of the button.

 @return New button instance.
*/
- (instancetype)initWithLabel:(NSString *)label color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END

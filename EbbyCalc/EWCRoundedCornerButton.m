//
//  EWCRoundedCornerButton.m
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

#import "EWCRoundedCornerButton.h"

@interface EWCRoundedCornerButton() {}

/**
  Stores ths normal background color so that it can be retrieved after the button has been highlighted.
 */
@property (nonatomic) UIColor *normalBackgroundColor;

@end

@implementation EWCRoundedCornerButton

///-----------------------------------------
/// @name Creation and Initilization Methods
///-----------------------------------------

+ (instancetype)buttonLabeled:(NSString *)label
  colored:(UIColor *)color
  backgroundColor:(UIColor *)backgroundColor {

  // allocate a new button and use the designated initializer
  EWCRoundedCornerButton *button = [[EWCRoundedCornerButton alloc]
    initWithLabel:label
    color:color
    backgroundColor:backgroundColor];

  return button;
}

- (instancetype)initWithLabel:(NSString *)label
  color:(UIColor *)color
  backgroundColor:(UIColor *)backgroundColor {

  self = [super init];
  if (self) {
    [self setBackgroundColor:backgroundColor];
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitle:label forState:UIControlStateNormal];

    // save the background color for later animations
    self.normalBackgroundColor = backgroundColor;

    // default the radius to -1, which will cause the button to auto calculate
    // the radius based on the layout width and height.
    self.cornerRadius = -1;
  }

  return self;
}

///---------------------
/// @name Layout Methods
///---------------------

/**
  Applies the designated corner radius (explicit or automatic) then defers to the superclass.
 */
- (void)layoutSubviews {
  NSInteger radius;

  if (_cornerRadius >= 0) {
    radius = _cornerRadius;
  } else {
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    radius = (h > w) ? w / 2 : h / 2;
  }

  self.layer.cornerRadius = radius;

  [super layoutSubviews];
}

///------------------------------------
/// @name Interaction Animation Methods
///------------------------------------

/**
  Updates the highlighted state by calling the superclass, animating any transition.

  @param highlighted The new highlight state.
 */
- (void)setHighlighted:(BOOL)highlighted {

  // only animate if there is a change
  BOOL doAnimate = highlighted != self.isHighlighted;

  // defer to the superclass for the default behavior
  [super setHighlighted:highlighted];

  if (doAnimate) {
    // only animate if a highlight color was set
    if (_highlightedBackgroundColor) {
      // weak references to avoid cycles
      __weak UIButton *button = self;
      __weak UIColor *hbg = _highlightedBackgroundColor;
      __weak UIColor *bg = _normalBackgroundColor;

      // halt any in-progress animations
      [self.layer removeAllAnimations];

      // start the new animation, but allow another press to interrupt it
      [UIView animateWithDuration:0.25 delay:0.0
        options:UIViewAnimationOptionAllowUserInteraction animations:^{
        button.backgroundColor = (highlighted) ? hbg : bg;
      } completion:nil];
    }
  }
}

///--------------------------------------------
/// @name Interaction and Accessibility Methods
///--------------------------------------------

/**
  Informs the parent view (we expect it to be a grid) whether a point lies inside the button.

  Usually, this would cause the parent view to give the event to the child to handle, but we want the grid to handle it so that dragging a finger across the app produces a nice highlight.  So we tell the parent the point is not in the button and let the grid figure it out using its own cell-based hit test.

  However, this causes a problem for VoiceOver, which will tell users that buttons are dimmed, so if VoiceOver is running, allow the regular hit test to run.  This disables the drag highlight, but dragging in VoiceOver is overridden anyway.

  @param point The point being queried.
  @param event The event related to the query point.

  @return YES if the point is in the control such as would make sense for the event, otherwise NO.  We always return NO for regular operation, but defer to the superclass when VoiceOver is running.
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (UIAccessibilityIsVoiceOverRunning()) {
    return [super pointInside:point withEvent:event];
  }

  return NO;
}

@end

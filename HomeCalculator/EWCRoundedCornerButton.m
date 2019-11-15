//
//  EWCRoundedCornerButton.m
//  HomeCalculator
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

@property (nonatomic) UIColor *normalBackgroundColor;

@end

@implementation EWCRoundedCornerButton

+ (instancetype)buttonLabeled:(NSString *)label
  colored:(UIColor *)color
  backgroundColor:(UIColor *)backgroundColor {

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

    self.normalBackgroundColor = backgroundColor;
    self.cornerRadius = -1;
  }

  return self;
}

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

- (void)setHighlighted:(BOOL)highlighted {
  BOOL doAnimate = highlighted != self.isHighlighted;

  [super setHighlighted:highlighted];

  if (doAnimate) {
    if (_highlightedBackgroundColor) {
      __weak UIButton *button = self;
      __weak UIColor *hbg = _highlightedBackgroundColor;
      __weak UIColor *bg = _normalBackgroundColor;
      [self.layer removeAllAnimations];
      [UIView animateWithDuration:0.25 delay:0.0
        options:UIViewAnimationOptionAllowUserInteraction animations:^{
        button.backgroundColor = (highlighted) ? hbg : bg;
      } completion:nil];
    }
  }
}

@end

//
//  EWCGridLayoutRoundedButton.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/9/19.
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

#import "EWCAccessibleRoundedCornerButton.h"

@implementation EWCAccessibleRoundedCornerButton

+ (instancetype)buttonLabeled:(NSString *)label
  colored:(UIColor *)color
  backgroundColor:(UIColor *)backgroundColor {

  EWCAccessibleRoundedCornerButton *button = [[EWCAccessibleRoundedCornerButton alloc]
    initWithLabel:label
    color:color
    backgroundColor:backgroundColor];

  return button;
}

- (instancetype)initWithLabel:(NSString *)label
  color:(UIColor *)color
  backgroundColor:(UIColor *)backgroundColor {

  self = [super initWithLabel:label color:color backgroundColor:backgroundColor];

  return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (UIAccessibilityIsVoiceOverRunning()) {
    return [super pointInside:point withEvent:event];
  }

  return NO;
}

@end

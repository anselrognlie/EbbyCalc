//
//  EWCGridLayoutRoundedButton.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/9/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

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

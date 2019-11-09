//
//  EWCRoundedCornerButton.m
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/23/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCRoundedCornerButton.h"

@interface EWCRoundedCornerButton() {}

@property (nonatomic) UIColor *normalBackgroundColor;

@end

@implementation EWCRoundedCornerButton

+ (instancetype)buttonLabeled:(NSString *)label
  colored:(UIColor *)color
  backgroundColor:(UIColor *)backgroundColor {

  EWCRoundedCornerButton *button = [EWCRoundedCornerButton new];
  [button setBackgroundColor:backgroundColor];
  [button setTitleColor:color forState:UIControlStateNormal];
  [button setTitle:label forState:UIControlStateNormal];

  button.normalBackgroundColor = backgroundColor;
  button.cornerRadius = -1;

  return button;
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
      [UIView animateWithDuration:0.25 animations:^{
        button.backgroundColor = (highlighted) ? hbg : bg;
      }];
    }
  }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (! _customPointTest) {
    return [super pointInside:point withEvent:event];
  }

  return _customPointTest(point, event, ^BOOL(CGPoint point, UIEvent * _Nullable event){
    return [super pointInside:point withEvent:event];
  });
}

//- (void)setCornerRadius:(NSInteger)value {
//  self.layer.cornerRadius = value;
//}
//
//- (NSInteger)cornerRadius {
//  return self.layer.cornerRadius;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

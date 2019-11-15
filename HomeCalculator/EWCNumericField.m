//
//  EWCNumericField.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/4/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCNumericField.h"

@implementation EWCNumericField

- (instancetype)init {
  self = [super init];
  if (self) {
    _value = [NSDecimalNumber zero];
    _empty = YES;
  }
  return self;
}

- (void)setValue:(NSDecimalNumber *)value {
  _value = value;
  _empty = NO;
}

- (void)clear {
  _value = [NSDecimalNumber zero];
  _empty = YES;
}

@end

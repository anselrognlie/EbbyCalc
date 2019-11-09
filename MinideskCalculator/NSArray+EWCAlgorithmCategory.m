//
//  NSArray+EWCAlgorithmCategory.m
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/7/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "NSArray+EWCAlgorithmCategory.h"

@implementation NSArray (EWCAlgorithmCategory)

- (CGFloat)ewc_totalDouble {
  CGFloat total = 0;
  for (NSNumber *num in self) {
    total += num.doubleValue;
  }

  return total;
}

- (CGFloat)ewc_minDouble {
  if (self.count == 0) {
    return 0;
  }

  CGFloat min = ((NSNumber *)self[0]).doubleValue;
  for (NSNumber *num in self) {
    CGFloat cmp = num.doubleValue;
    if (cmp < min) {
      min = cmp;
    }
  }

  return min;
}

@end

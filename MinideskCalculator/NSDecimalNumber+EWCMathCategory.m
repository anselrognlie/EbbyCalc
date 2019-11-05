//
//  NSDecimalNumber+EWCMathCategory.m
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/3/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "NSDecimalNumber+EWCMathCategory.h"

#import <AppKit/AppKit.h>

static BOOL diffWithinDelta(NSDecimalNumber *n1, NSDecimalNumber *n2, NSDecimalNumber *delta) {
  NSDecimalNumber *diff = [n1 ewc_decimalNumberByAbsoluteDifferenceFrom:n2];
  if ([diff compare:delta] == NSOrderedAscending) {
    return YES;
  }

  return NO;
}


@implementation NSDecimalNumber (EWCMathCategory)

-(NSDecimalNumber *)ewc_decimalNumberBySqrt {
  // if value < 0, result is not a number
  // if value == 0, result is 0
  // if value == 1, result is 1
  // otherwise, apply newton's method to solve

  // sqrt of a number n is really the root of the equation f(x) = x^2 - n
  // so use newton's method to estimate the root
  // the steps are:
  // 1. make an initial guess g0 = (n + 1) / 2 = (1/2)(n + 1)
  // 2. estimate the next guess gn+1 = gn - (f(gn) / f'(gn))
  // 3. repeat 2 until there is convergeance |gn+1 - gn| < delta
  //    or we reach some max number of iterations
  // be careful to avoid dividing by zero

  // since f(x) is of a fixed form, we also know that f'(x) = 2x
  // so step 2 evaluates to
  // gn+1 = gn - ((gn^2 - n) / (2gn)) = gn - (.5gn - (n / 2gn))
  //      = gn -.5gn + (n / 2gn) = (1/2)gn + (n / 2gn)
  //      = (1/2)(gn + (n / gn))

  if ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
    return [NSDecimalNumber notANumber];
  }

  if ([self compare:[NSDecimalNumber zero]] == NSOrderedSame ||
    [self compare:[NSDecimalNumber one]] == NSOrderedSame) {
    return [self copy];
  }

  NSDecimalNumber *half = [NSDecimalNumber decimalNumberWithMantissa:5 exponent:-1 isNegative:NO];
  NSDecimalNumber *delta = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:-20 isNegative:NO];
  NSDecimalNumber *guess = [[self decimalNumberByAdding:[NSDecimalNumber one]]
    decimalNumberByMultiplyingBy:half];

  const int maxIter = 30;
  for (int i = 0; i < maxIter; ++i) {
    if ([guess compare:[NSDecimalNumber zero]] == NSOrderedSame) {
      break;
    }

    NSDecimalNumber *last = guess;
    guess = [[[self decimalNumberByDividingBy:guess]
      decimalNumberByAdding:guess] decimalNumberByMultiplyingBy:half];

    if (diffWithinDelta(last, guess, delta)) {
//      NSLog(@"sqrt iter: %d", i);
      break;
    }
  }

  return guess;
}

- (NSDecimalNumber *)ewc_decimalNumberBySqrtWithBehavior:(NSDecimalNumberHandler *)handler {
  NSDecimalNumber *result = [self ewc_decimalNumberBySqrt];
  return [result decimalNumberByRoundingAccordingToBehavior:handler];
}

- (NSDecimalNumber *)ewc_decimalNumberByAbsoluteDifferenceFrom:(NSDecimalNumber *)aNumber {

  NSDecimalNumber *n1 = self;
  
  // make sure n1 is bigger
  if ([n1 compare:aNumber] == NSOrderedAscending) {
    NSDecimalNumber *tmp = aNumber;
    aNumber = n1;
    n1 = tmp;
  }

  return [n1 decimalNumberBySubtracting:aNumber];
}

@end

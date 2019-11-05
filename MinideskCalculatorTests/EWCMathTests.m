//
//  EWCMathTests.m
//  MinideskCalculatorTests
//
//  Created by Ansel Rognlie on 11/3/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../MinideskCalculator/NSDecimalNumber+EWCMathCategory.h"

typedef struct {
  NSDecimalNumber *in;
  NSDecimalNumber *out;
} EWCNumberInOutTestCase;

static NSDecimalNumber *makeDecimal(double d) {
  return [[NSDecimalNumber alloc] initWithDouble:d];
}

@interface EWCMathTests : XCTestCase

@end

@implementation EWCMathTests

-(void)testSqrt {
  NSDecimalNumber *value, *result;
  EWCNumberInOutTestCase cases[] = {
    { [NSDecimalNumber zero], [NSDecimalNumber zero] },
    { [NSDecimalNumber one], [NSDecimalNumber one] },
    { makeDecimal(-1), [NSDecimalNumber notANumber] },
  };
  const int NUM_CASES = sizeof(cases) / sizeof(0[cases]);

  NSDecimalNumberHandler *handler = [NSDecimalNumberHandler
    decimalNumberHandlerWithRoundingMode:NSRoundPlain
    scale:10 raiseOnExactness:NO
    raiseOnOverflow:NO
    raiseOnUnderflow:NO
    raiseOnDivideByZero:NO];

  for (int i = 0; i < NUM_CASES; ++i) {
    value = cases[i].in;
    result = [value ewc_decimalNumberBySqrt];
    XCTAssertEqualObjects(result, cases[i].out, @"SQRT(%@)", value);
  }

  // check a bunch of numbers
  for (int i = 2; i < 500; ++i) {
    double d = i * i;
    double input = d * d;
    value = makeDecimal(input);
    result = [value ewc_decimalNumberBySqrtWithBehavior:handler];

    XCTAssertEqualObjects(result, makeDecimal(d), @"SQRT(%@)", value);
  }
}

@end

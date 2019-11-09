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

- (void)testDigitClamp {
  NSDecimalNumber *num, *clamp;
  NSString *str;

  // positive

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:0 isNegative:NO]; // 314
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertNil(clamp, @"%@ doesn't fit in 2 digits", num);

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-1 isNegative:NO]; // 31.4
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"31", str, @"should have dropped all decimals");

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-2 isNegative:NO]; // 3.14
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"3.1", str, @"should have one decimal digit");

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-3 isNegative:NO]; // 0.314
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"0.3", str, @"should have one decimal digit");

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-4 isNegative:NO]; // 0.0314
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"0", str, @"should clamp to zero");

  // negative

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:0 isNegative:YES]; // -314
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertNil(clamp, @"%@ doesn't fit in 2 digits", num);

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-1 isNegative:YES]; // -31.4
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"-31", str, @"should have dropped all decimals");

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-2 isNegative:YES]; // -3.14
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"-3.1", str, @"should have one decimal digit");

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-3 isNegative:YES]; // -0.314
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"-0.3", str, @"should have one decimal digit");

  num = [NSDecimalNumber decimalNumberWithMantissa:314 exponent:-4 isNegative:YES]; // -0.0314
  clamp = [num ewc_decimalNumberByRestrictingToDigits:2];
  str = [clamp stringValue];
  NSLog(@"num: %@, clamp: %@", num, clamp);
  XCTAssertEqualObjects(@"0", str, @"should clamp to zero");

}

@end

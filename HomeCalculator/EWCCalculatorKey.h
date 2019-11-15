//
//  EWCCalculatorKey.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EWCCalculatorKey) {
  EWCCalculatorNoKey = -1,
  EWCCalculatorZeroKey,
  EWCCalculatorOneKey,
  EWCCalculatorTwoKey,
  EWCCalculatorThreeKey,
  EWCCalculatorFourKey,
  EWCCalculatorFiveKey,
  EWCCalculatorSixKey,
  EWCCalculatorSevenKey,
  EWCCalculatorEightKey,
  EWCCalculatorNineKey,
  EWCCalculatorClearKey,
  EWCCalculatorRateKey,
  EWCCalculatorTaxPlusKey,
  EWCCalculatorTaxMinusKey,
  EWCCalculatorMemoryKey,
  EWCCalculatorMemoryPlusKey,
  EWCCalculatorMemoryMinusKey,
  EWCCalculatorAddKey,
  EWCCalculatorSubtractKey,
  EWCCalculatorMultiplyKey,
  EWCCalculatorDivideKey,
  EWCCalculatorSignKey,
  EWCCalculatorDecimalKey,
  EWCCalculatorPercentKey,
  EWCCalculatorSqrtKey,
  EWCCalculatorEqualKey,
};

BOOL EWCCalculatorKeyIsBinaryOp(EWCCalculatorKey key);
BOOL EWCCalculatorKeyIsRateKey(EWCCalculatorKey key);

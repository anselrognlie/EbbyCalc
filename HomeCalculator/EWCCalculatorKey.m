//
//  EWCCalculatorKey.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWCCalculatorKey.h"

BOOL EWCCalculatorKeyIsBinaryOp(EWCCalculatorKey key) {
  switch (key) {
    case EWCCalculatorAddKey:
    case EWCCalculatorSubtractKey:
    case EWCCalculatorMultiplyKey:
    case EWCCalculatorDivideKey:
      return YES;

    default:
      return NO;
  }
}

BOOL EWCCalculatorKeyIsRateKey(EWCCalculatorKey key) {
  switch (key) {
    case EWCCalculatorRateKey:
    case EWCCalculatorTaxPlusKey:
    case EWCCalculatorTaxMinusKey:
      return YES;

    default:
      return NO;
  }
}

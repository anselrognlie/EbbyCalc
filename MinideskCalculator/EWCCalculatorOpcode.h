//
//  EWCCalculatorOpcode.m
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EWCCalculatorOpcode) {
  EWCCalculatorNoOpcode = 1,
  EWCCalculatorAddOpcode,
  EWCCalculatorSubtractOpcode,
  EWCCalculatorMultiplyOpcode,
  EWCCalculatorDivideOpcode,
  EWCCalculatorPercentOpcode,
  EWCCalculatorEqualOpcode,
};

BOOL EWCCalculatorOpcodeIsBinaryOp(EWCCalculatorOpcode opcode);

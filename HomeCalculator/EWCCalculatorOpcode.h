//
//  EWCCalculatorOpcode.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EWCCalculatorOpcode) {
  EWCCalculatorNoOpcode = 0,
  EWCCalculatorAddOpcode,
  EWCCalculatorSubtractOpcode,
  EWCCalculatorMultiplyOpcode,
  EWCCalculatorDivideOpcode,
  EWCCalculatorAddPercentOpcode,
  EWCCalculatorSubtractPercentOpcode,
  EWCCalculatorMultiplyPercentOpcode,
  EWCCalculatorDividePercentOpcode,
  EWCCalculatorPercentOpcode,
  EWCCalculatorEqualOpcode,
};

BOOL EWCCalculatorOpcodeIsBinaryOp(EWCCalculatorOpcode opcode);
EWCCalculatorOpcode
  EWCCalculatorOpcodeModifyForEqualMode(
  EWCCalculatorOpcode opcode,
  EWCCalculatorOpcode mode);

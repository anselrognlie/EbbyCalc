//
//  EWCCalculatorOpcode.m
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWCCalculatorOpcode.h"

BOOL EWCCalculatorOpcodeIsBinaryOp(EWCCalculatorOpcode opcode) {
  switch (opcode) {
    case EWCCalculatorAddOpcode:
    case EWCCalculatorSubtractOpcode:
    case EWCCalculatorMultiplyOpcode:
    case EWCCalculatorDivideOpcode:
      return YES;

    default:
      return NO;
  }
}

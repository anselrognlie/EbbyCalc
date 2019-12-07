//
//  EWCCalculatorOpcode.m
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>
#import "EWCCalculatorOpcode.h"

BOOL EWCCalculatorOpcodeIsBinaryOp(EWCCalculatorOpcode opcode) {
  // the usual add, subtract, multiply, and divide are considered binary operations.
  // the percent variations are not considered so, as the will not appear in the
  // conditions this check is used.
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

EWCCalculatorOpcode
  EWCCalculatorOpcodeModifyForEqualMode(
  EWCCalculatorOpcode opcode,
  EWCCalculatorOpcode mode) {

  // only modify the opcode if the mode is percent
  if (mode == EWCCalculatorPercentOpcode) {
    return opcode + (EWCCalculatorAddPercentOpcode - EWCCalculatorAddOpcode);
  }

  return opcode;
}

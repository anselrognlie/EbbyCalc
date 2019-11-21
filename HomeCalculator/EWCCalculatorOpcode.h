//
//  EWCCalculatorOpcode.m
//  HomeCalculator
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

/**
  `EWCCalculatorOpcode` represents an operation (stored in an `EWCCalculatorToken`) that is placed in the calculator operation queue.
 */
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

/**
  Determines whether an opcode represents a binary operation.

  @param opcode The opcode to examine.

  @return YES if the opcode is a binary operation, otherwise NO.
 */
BOOL EWCCalculatorOpcodeIsBinaryOp(EWCCalculatorOpcode opcode);

/**
  Modifies an opcode to a percent operation if the supplied equal mode is a percent calculation.

  @param opcode The operation to potentially modify.
  @param mode The calculation mode, expected to be either equal or percent.

  @return Returns a modified opcode if the supplied mode is percent, otherwise it just gives back the same opcode.
 */
EWCCalculatorOpcode
  EWCCalculatorOpcodeModifyForEqualMode(
  EWCCalculatorOpcode opcode,
  EWCCalculatorOpcode mode);

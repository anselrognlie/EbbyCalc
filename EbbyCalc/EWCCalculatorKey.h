//
//  EWCCalculatorKey.h
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

/**
  `EWCCalculatorKey` represents each of the keys of the `EWCCalculator`.
 */
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
  EWCCalculatorBackspaceKey,
};

/**
  Determines whether a key represents a binary operation.

  @param key The key to examine.

  @return YES if the key is a binary operation, otherwise NO.
*/
BOOL EWCCalculatorKeyIsBinaryOp(EWCCalculatorKey key);

/**
  Determines whether a key is related to setting the tax rate.

  @param key The key to examine.

  @return YES if the key is related to setting the tax rate.
 */
BOOL EWCCalculatorKeyIsRateKey(EWCCalculatorKey key);

/**
  Determines whether a key is a digit.

  @param key The key to examine.

  @return YES if the key is a digit, otherwise NO.
 */
BOOL EWCCalculatorKeyIsDigit(EWCCalculatorKey key);

/**
  Gets the numeric value of the provided key.

  @param key The digit key.

  @return The numeric value of the key, or -1 if the key is not a numeric key.
*/
short EWCCalculatorDigitFromKey(EWCCalculatorKey key);

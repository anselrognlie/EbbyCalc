//
//  NSDecimalNumber+EWCMathCategory.h
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/3/19.
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

NS_ASSUME_NONNULL_BEGIN

/**
 `NSDecimalNumber+EWCMathCategory` contains additional mathematical operations implemented on `NSDecimalNumber` instances.
*/
@interface NSDecimalNumber (EWCMathCategory)

/**
  Finds the square root of the `NSDecimalNumber` and returns it as a new instance.

  @return A new `NSDecimalNumber` which is the square root of the instance.  If called on a negative number, NaN is returned.
 */
-(NSDecimalNumber *)ewc_decimalNumberBySqrt;

/**
 Finds the square root of the `NSDecimalNumber` and returns it as a new instance, applying the rounding behavior specified in the `NSDecimalNumberHandler`.

 @param handler The rounding behavior to apply to the square root result.

 @return A new `NSDecimalNumber` which is the square root of the instance, with the supplied behavior applied.
 */
-(NSDecimalNumber *)ewc_decimalNumberBySqrtWithBehavior:(NSDecimalNumberHandler *)handler;

/**
  Finds the difference between two `NSDecimalNumber` instances.

  @param aNumber The `NSDecimalNumber` for which to find the difference from the current value.

  @return A new `NSDecimalNumber` which is the difference between the current number and the supplied parameter.
*/
-(NSDecimalNumber *)ewc_decimalNumberByAbsoluteDifferenceFrom:(NSDecimalNumber *)aNumber;

/**
  Rounds the instance to the specified number of digits.

  @param digits The number of digits to which to round the value.

  @return A new `NSDecimalNumber` which is the value rounded to the supplied number of digits.  If it cannot fit, nil is returned.
 */
-(NSDecimalNumber *)ewc_decimalNumberByRestrictingToDigits:(unsigned short)digits;

@end

NS_ASSUME_NONNULL_END

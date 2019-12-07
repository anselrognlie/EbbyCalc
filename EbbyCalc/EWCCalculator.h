//
//  EWCCalculator.h
//  EbbyCalc
//
//  Created by Ansel Rognlie on 10/29/19.
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
#import "EWCCalculatorKey.h"

@protocol EWCCalculatorDataProtocol;

NS_ASSUME_NONNULL_BEGIN

/**
  `EWCCalculatorUpdatedCallback` defines the callback notification signature used to notify a listener that the calculator state has changed.
 */
typedef void(^EWCCalculatorUpdatedCallback)(void);

/**
  `EWCCalculator` provides the calculator logic, interpretting virtual button presses as actions on the calculator, updating state and results, and notifying a listener of state changes.  It provides no UI, it is just the logical core.
 */
@interface EWCCalculator : NSObject

/**
  Whether or not the calculator has stored memory.
 */
@property (nonatomic, readonly, getter=hasMemory) BOOL memoryStatusVisible;

/**
  Whether or not the calculator is in an error state.
 */
@property (nonatomic, readonly, getter=hasError) BOOL error;

/**
  Whether or not an indicator showing that the current value is a tax result should be visible.
 */
@property (nonatomic, readonly, getter=isTaxStatusVisible) BOOL taxStatusVisible;

/**
  Whether or not an indicator showing that the current value is a tax-including result should be visible.
 */
@property (nonatomic, readonly, getter=isTaxPlusStatusVisible) BOOL taxPlusStatusVisible;

/**
  Whether or not an indicator showing that the current value is a tax-excluding result should be visible.
 */
@property (nonatomic, readonly, getter=isTaxMinusStatusVisible) BOOL taxMinusStatusVisible;

/**
  Whether or not an indicator showing that the current value is the tax percentage should be visible.
 */
@property (nonatomic, readonly, getter=isTaxPercentStatusVisible) BOOL taxPercentStatusVisible;

/**
  Whether or not the calculator is in rate-shifted state.
 */
@property (nonatomic, readonly, getter=isRateShifted) BOOL rateShifted;

/**
  Whether or not the next mrc press will act as a clear operation.
 */
@property (nonatomic, readonly) BOOL shouldMemoryClear;

/**
  The calculator display formatted as a string.
 */
@property (nonatomic, readonly) NSString *displayContent;

/**
  The calculator display as a raw NSDecimalNumber.
 */
@property (nonatomic, readonly) NSDecimalNumber *displayValue;

/**
 The calculator display formatted for accessibility VoiceOver (effectively a spelled out locale-specific reading).
 */
@property (nonatomic, readonly) NSString *displayAccessibleContent;

/**
  The number of digits to which to restrict calculations.
 */
@property (nonatomic) NSInteger maximumDigits;

/**
  An `EWCCalculatorDataProtocol` instance that the calculator can use to store and retrieve persistent values.
 */
@property (nonatomic, copy) id<EWCCalculatorDataProtocol> dataProvider;

/**
  Explicitly provides a locale to use for the calculator.  If not supplied, it will default to the locale set at the time the calculator is created.
*/
@property (nonatomic, copy) NSLocale *locale;

/**
  Creates a new calculator.
 */
+ (instancetype)calculator;

/**
  Sets the callback to use to notify a listener that the calculator state has changed.
 */
- (void)registerUpdateCallbackWithBlock:(EWCCalculatorUpdatedCallback)callback;

/**
  Explicitly sets the current display input to a supplied numeric value rather than performing key inputs.

  This will not allow getting arround the digit limit, as that is checked every time the display is set, so setting too large a value will result in an error state.
 */
- (void)setInput:(NSDecimalNumber *)value;

/**
  Perform a key press on the calculator.  This is the primary way a client should provide input to the calculator.
 */
- (void)pressKey:(EWCCalculatorKey)key;

@end

NS_ASSUME_NONNULL_END

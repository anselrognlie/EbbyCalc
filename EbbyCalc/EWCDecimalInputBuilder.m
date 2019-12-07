//
//  EWCDecimalInputBuilder.m
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/24/19.
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

#import "EWCDecimalInputBuilder.h"
#import "NSDecimalNumber+EWCMathCategory.h"

/**
  `EWCCalculatorInputMode` tracks whether the input state is receiving digits that are part of the whole number, or the fraction.
 */
typedef NS_ENUM(NSInteger, EWCCalculatorInputMode) {
  EWCCalculatorInputModeWhole = 1,
  EWCCalculatorInputModeFraction,
};

@interface EWCDecimalInputBuilder () {
  BOOL _editing;  // NO when user hasn't contributed to input yet
  EWCCalculatorInputMode _inputMode;  // track whether input digits are for the whole or fractional part of a number
  short _fractionPower;  // power of the fractional digit being added.  ranges from 0 to more negative values.  treated as the power of ten of the next fraction digit
  short _sign;  // the sign of the number being built up in the display
  short _numDigits;  // the number of digits accumulated in the input display
  NSDecimalNumber *_value;  // the decimal value being built up through user interactions
}

@end

@implementation EWCDecimalInputBuilder

///-------------------
/// @name Initializers
///-------------------

/**
  Intializes a new input builder in an empty state.

  @return The initialized instance.
 */
- (instancetype)init {
  self = [super init];
  if (self) {
    [self clear];
  }

  return self;
}

///------------------------------
/// @name Custom Property Methods
///------------------------------

- (short)fractionalDigitCount {
  return -_fractionPower;
}

- (void)setValue:(NSDecimalNumber *)value {
  [self clear];
  _value = value;
}

///---------------------
/// @name Public Methods
///---------------------

- (void)clear {
  _inputMode = EWCCalculatorInputModeWhole;
  _fractionPower = 0;
  _sign = 1;
  _numDigits = 0;
  _editing = NO;
  _value = [NSDecimalNumber zero];
}

- (BOOL)processKey:(EWCCalculatorKey)key {
  BOOL ok = NO;

  if (EWCCalculatorKeyIsDigit(key)) {
    short digit = EWCCalculatorDigitFromKey(key);
    if (digit != -1) {
      ok = YES;
      [self digitPressed:digit];
    }
  } else if (key == EWCCalculatorSignKey) {
    ok = YES;
    [self signPressed];
  } else if (key == EWCCalculatorDecimalKey) {
    ok = YES;
    [self decimalPressed];
  } else if (key == EWCCalculatorBackspaceKey) {
    ok = YES;
    [self backspacePressed];
  }

  // this isn't a key we handle, then no longer editing
  if (! ok) {
    _editing = NO;
  }

  return ok;
}

///-----------------------------
/// @name Press Handling Methods
///-----------------------------

/**
  Appends a supplied digit to the number being built up.  If the key is the first in a series of keys we can handle, may sure we start in a fresh state.

  @param digit The digit to append to the in-progress number.
 */
- (void)digitPressed:(int)digit {
  if (! _editing) {
    [self clear];
    _editing = YES;
  }

  digit *= _sign;

  // don't allow input of more than maximum digits
  if (_maximumDigits && (_numDigits + 1 > _maximumDigits)) {
    return;
  }

  switch (_inputMode) {
    case EWCCalculatorInputModeWhole: {
      // add to the whole number part by decimal left shifting the number we have so far
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      NSDecimalNumber *tmp = [_value decimalNumberByMultiplyingByPowerOf10:1];
      _value = [tmp decimalNumberByAdding:decimalDigit];
    }
    break;

    case EWCCalculatorInputModeFraction: {
      // if we had no digits, then this is the first, so increment again, as we
      // must have a leading zero
      if (! _numDigits) {
        _numDigits = 1;
      }

      // add to the fraction part by decimal right shifting to the appropriate power of 10
      _fractionPower--;
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      decimalDigit = [decimalDigit decimalNumberByMultiplyingByPowerOf10:_fractionPower];
      _value = [_value decimalNumberByAdding:decimalDigit];
    }
    break;
  }

  ++_numDigits;
}

/**
  Toggle the sign of the number.
 */
- (void)signPressed {
  if ([_value isEqualToNumber:@0]) { return; }

  _sign = -_sign;

  NSDecimalNumber *minusOne = [[NSDecimalNumber alloc] initWithInt:-1];
  _value = [_value decimalNumberByMultiplyingBy:minusOne];
}

/**
  Insert an explicit decimal point.  Any digits after this will start being added to the fractional part of the number.
 */
- (void)decimalPressed {
  if (! _editing) {
    [self clear];
    _editing = YES;
  }

  // do we already have a decimal
  if (_inputMode != EWCCalculatorInputModeWhole) { return; }

  _inputMode = EWCCalculatorInputModeFraction;
  _fractionPower = 0;
}

/**
  Remove the terminal character if editing.
 */
- (void)backspacePressed {
  if (! _editing) {
    return;
  }

  if (_numDigits == 0) {
    // nothing to do
    return;
  }

  if (_numDigits == 1) {
    // just replace with 0
    _value = [NSDecimalNumber zero];
    _numDigits = 0;
    _sign = 1;
    return;
  }

  // if the number is negative, note that and flip it positive
  NSDecimalNumber *value = _value;
  int sign = 1;
  if ([value compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
    sign = -1;
    value = [[NSDecimalNumber zero] decimalNumberBySubtracting:value];
  }

  switch (_inputMode) {
    case EWCCalculatorInputModeWhole: {
      // shift down by a power of ten then round away the decimal
      value = [value decimalNumberByMultiplyingByPowerOf10:-1];

      // remove the final digit by rounding down the final power
      NSDecimalNumberHandler *formatter = [NSDecimalNumberHandler
        decimalNumberHandlerWithRoundingMode:NSRoundDown
        scale:0
        raiseOnExactness:NO
        raiseOnOverflow:NO
        raiseOnUnderflow:NO
        raiseOnDivideByZero:NO];

      // add to the fraction part by decimal right shifting to the appropriate power of 10
      value = [value decimalNumberByRoundingAccordingToBehavior:formatter];

    }
    break;

    case EWCCalculatorInputModeFraction: {
      _fractionPower++;

      // remove the final digit by rounding down the final power
      NSDecimalNumberHandler *formatter = [NSDecimalNumberHandler
        decimalNumberHandlerWithRoundingMode:NSRoundDown
        scale:(-_fractionPower)
        raiseOnExactness:NO
        raiseOnOverflow:NO
        raiseOnUnderflow:NO
        raiseOnDivideByZero:NO];

      // add to the fraction part by decimal right shifting to the appropriate power of 10
      value = [value decimalNumberByRoundingAccordingToBehavior:formatter];

      if (_fractionPower == 0) {
        _inputMode = EWCCalculatorInputModeWhole;

        // numDigits can be off if there was no whole part, so do a hard check for zero here
        if ([value compare:[NSDecimalNumber zero]] == NSOrderedSame) {
          _numDigits = 0;
          _sign = 1;
        }
      }
    }
    break;
  }

  --_numDigits;

  // restore the sign
  if (sign < 0) {
    value = [[NSDecimalNumber zero] decimalNumberBySubtracting:value];
  }

  _value = value;
}

@end

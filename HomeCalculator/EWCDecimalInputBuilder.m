//
//  EWCDecimalInputBuilder.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/24/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

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

@end

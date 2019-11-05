//
//  EWCCalculator.m
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/29/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCCalculator.h"
#import "NSDecimalNumber+EWCMathCategory.h"

typedef NS_ENUM(NSInteger, EWCCalculatorInputMode) {
  EWCCalculatorInputModeRegular = 1,
  EWCCalculatorInputModeFraction,
};

typedef NS_ENUM(NSInteger, EWCCalculatorOperator) {
  EWCCalculatorNoOperator = 1,
  EWCCalculatorAddOperator,
  EWCCalculatorSubtractOperator,
  EWCCalculatorMultiplyOperator,
  EWCCalculatorDivideOperator,
};

typedef NS_ENUM(NSInteger, EWCCalculatorState) {
  EWCCalculatorStartState = 1,
  EWCCalculatorReadyState,
  EWCCalculatorCalculatedState,
  EWCCalculatorCalculatedOperandState,
  EWCCalculatorFirstInputState,
  EWCCalculatorSecondInputState,
  EWCCalculatorOperandState,
  EWCCalculatorSecondClearedState,
  EWCCalculatorErrorState,
  EWCCalculatorErrorClearedState,
  EWCCalculatorRateShiftedState,
  EWCCalculatorShowTaxState,
};

@interface EWCCalculator() {
  EWCCalculatorUpdatedCallback _callback;
  BOOL _shift;
  BOOL _error;
  NSDecimalNumber *_accumulator;
  NSDecimalNumber *_input;
  BOOL _inputClearsCurrent;
  NSDecimalNumber *_taxRate;
  NSDecimalNumber *_memory;
  NSDecimalNumber *_operand;
  EWCCalculatorOperator _operator;
  NSNumberFormatter *_formatter;
  EWCCalculatorInputMode _inputMode;
  short _fractionPower;
  short _sign;
  EWCCalculatorState _state;
  EWCCalculatorState _unshiftState;
  EWCCalculatorKey _key;

  // fields for tracking values before we know whether we are performing a
  // unary or binary operation
  NSDecimalNumber *_pendingInput;
  EWCCalculatorOperator _pendingOperator;
}

@property (nonatomic, getter=isMemoryStatusVisible) BOOL memoryStatusVisible;
@property (nonatomic, getter=isTaxStatusVisible) BOOL taxStatusVisible;
@property (nonatomic, getter=isTaxPlusStatusVisible) BOOL taxPlusStatusVisible;
@property (nonatomic, getter=isTaxMinusStatusVisible) BOOL taxMinusStatusVisible;
@property (nonatomic, getter=isTaxPercentStatusVisible) BOOL taxPercentStatusVisible;
@property (nonatomic) NSDecimalNumber *displayValue;

@end

@implementation EWCCalculator

+ (instancetype)calculator {
  return [EWCCalculator new];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self sharedInit];
  }

  return self;
}

- (void)sharedInit {
  _memoryStatusVisible = NO;
  _taxStatusVisible = NO;
  _taxPlusStatusVisible = NO;
  _taxMinusStatusVisible = NO;
  _taxPercentStatusVisible = NO;
  _error = NO;
  _state = EWCCalculatorReadyState;
  _inputClearsCurrent = YES;

  _taxRate = [NSDecimalNumber zero];
  _memory = [NSDecimalNumber zero];
  _formatter = [self getFormatter];
  _state = EWCCalculatorStartState;
  _key = EWCCalculatorNoKey;

  [self fullClear];
}

- (NSNumberFormatter *)getFormatter {
  NSNumberFormatter *formatter = [NSNumberFormatter new];

  formatter.maximumFractionDigits = 20;

  return formatter;
}

- (void)registerUpdateCallbackWithBlock:(EWCCalculatorUpdatedCallback)callback {
  _callback = callback;
}

- (NSString *)displayContent {

  NSDecimalNumber *value = self.displayValue;
  NSString *display = [_formatter stringFromNumber:value];

  display = [self processDisplay:display];

  return display;
}

- (NSDecimalNumber *)displayValue {

  NSDecimalNumber *display;

  switch (_state) {
    case EWCCalculatorCalculatedState:
    case EWCCalculatorCalculatedOperandState:
    case EWCCalculatorErrorState:
    case EWCCalculatorErrorClearedState:
      display = [_accumulator copy];
      break;

    default:
      display = [_input copy];
      break;
  }

  return display;
}

- (void)setDisplayValue:(NSDecimalNumber *)value {

  switch (_state) {
    case EWCCalculatorCalculatedState:
    case EWCCalculatorCalculatedOperandState:
    case EWCCalculatorErrorState:
    case EWCCalculatorErrorClearedState:
      _accumulator = [value copy];
      break;

    default:
      _input = [value copy];
      _inputClearsCurrent = YES;
      break;
  }
}

- (NSString *)processDisplay:(NSString *)display {
  // append decimal if needed
  if (! [display containsString:@"."]) {
    display = [display stringByAppendingString:@"."];
  }

  return display;
}

- (BOOL)isRateShifted {
  return _shift;
}

- (BOOL)isErrorStatusVisible {
  return _state == EWCCalculatorErrorState;
}

- (void)fullClear {
  [self clearInput];
  [self clearAccumulator];
  [self clearOperand];
  _operator = EWCCalculatorNoOperator;
}

- (void)clearInput {
  _input = [NSDecimalNumber zero];
  _inputMode = EWCCalculatorInputModeRegular;
  _fractionPower = 0;
  _sign = 1;
  _formatter.minimumFractionDigits = 0;
  _shift = NO;
  _inputClearsCurrent = YES;
}

- (void)clearAccumulator {
  _accumulator = [NSDecimalNumber zero];
}

- (void)clearOperand {
  _operand = [NSDecimalNumber zero];
}

- (void)copyToAccumulator:(NSDecimalNumber *)number {
  _accumulator = [number copy];
}

- (void)copyToOperand:(NSDecimalNumber *)number {
  _operand = [number copy];
}

- (void)copyToInput:(NSDecimalNumber *)number {
  _input = [number copy];
}

- (void)digitPressed:(int)digit {
  // no action if in error state
  if ([self isInErrorState]) { return; }

  if (_inputClearsCurrent) {
    [self clearInput];
    _inputClearsCurrent = NO;
  }

  digit *= _sign;

  switch (_inputMode) {
    case EWCCalculatorInputModeRegular: {
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      _input = [_input decimalNumberByMultiplyingByPowerOf10:1];
      _input = [_input decimalNumberByAdding:decimalDigit];
    }
    break;

    case EWCCalculatorInputModeFraction: {
      _fractionPower--;
      _formatter.minimumFractionDigits = -_fractionPower;
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      decimalDigit = [decimalDigit decimalNumberByMultiplyingByPowerOf10:_fractionPower];
      _input = [_input decimalNumberByAdding:decimalDigit];
    }
    break;
  }
}

- (void)setOperator:(EWCCalculatorOperator)op {
  if ([self isInErrorState]) { return; }

  // queue the pending operator
  _operator = op;
}

// returns NO on error
- (BOOL)performOperation {

//  if ((_operator == EWCCalculatorDivideOperator
//    && [_operand isEqualToNumber:@0])
//    || _operator == EWCCalculatorNoOperator) {
//    return NO;
//  }

  if (_operator == EWCCalculatorDivideOperator
    && [_operand isEqualToNumber:@0]) {
    return NO;
  }

  switch (_operator) {
    case EWCCalculatorAddOperator:
      _accumulator = [_accumulator decimalNumberByAdding:_operand];
      break;

    case EWCCalculatorSubtractOperator:
      _accumulator = [_accumulator decimalNumberBySubtracting:_operand];
      break;

    case EWCCalculatorMultiplyOperator:
      _accumulator = [_accumulator decimalNumberByMultiplyingBy:_operand];
      break;

    case EWCCalculatorDivideOperator:
      _accumulator = [_accumulator decimalNumberByDividingBy:_operand];
      break;

    case EWCCalculatorNoOperator:
      break;
  }

  return YES;
}

// returns NO on error
- (BOOL)performUnaryOperation {

  if ((_operator == EWCCalculatorDivideOperator
    && [_operand isEqualToNumber:@0])
    || _operator == EWCCalculatorNoOperator) {
    return NO;
  }

  switch (_operator) {
    case EWCCalculatorAddOperator:
      _accumulator = [NSDecimalNumber zero];
      _accumulator = [_accumulator decimalNumberByAdding:_operand];
      break;

    case EWCCalculatorSubtractOperator:
      _accumulator = [NSDecimalNumber zero];
      _accumulator = [_accumulator decimalNumberBySubtracting:_operand];
      break;

    case EWCCalculatorMultiplyOperator:
      _accumulator = [_operand copy];
      _accumulator = [_accumulator decimalNumberByMultiplyingBy:_operand];
      break;

    case EWCCalculatorDivideOperator:
      _accumulator = [NSDecimalNumber one];
      _accumulator = [_accumulator decimalNumberByDividingBy:_operand];
      break;

    case EWCCalculatorNoOperator:
      break;
  }

  return YES;
}

- (BOOL)performSqrt {
  BOOL ok = YES;

  // get whatever value is currently displayed
  NSDecimalNumber *num = self.displayValue;

  // if the value is negative, treat it as positive, but set the error
  if ([num compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
    ok = NO;
    num = [num decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:-1]];
  }

  // take sqrt, but guarantee no more than 10 digits of accuracy
  NSDecimalNumberHandler *handler = [NSDecimalNumberHandler
    decimalNumberHandlerWithRoundingMode:NSRoundPlain
    scale:10 raiseOnExactness:NO
    raiseOnOverflow:NO
    raiseOnUnderflow:NO
    raiseOnDivideByZero:NO];

  num = [num ewc_decimalNumberBySqrtWithBehavior:handler];

  // write back to where we got the value
  self.displayValue = num;

  return ok;
}

- (void)signPressed {
  // no action if in error state
  if ([self isInErrorState]) { return; }

  if ([_input isEqualToNumber:@0]) { return; }

  _sign = -_sign;

  NSDecimalNumber *minusOne = [[NSDecimalNumber alloc] initWithInt:-1];
  _input = [_input decimalNumberByMultiplyingBy:minusOne];
}

- (void)invertAccumulator {
  // no action if in error state
  if ([self isInErrorState]) { return; }

  if ([_accumulator isEqualToNumber:@0]) { return; }

  NSDecimalNumber *minusOne = [[NSDecimalNumber alloc] initWithInt:-1];
  _accumulator = [_accumulator decimalNumberByMultiplyingBy:minusOne];
}


- (void)decimalPressed {
  if ([self isInErrorState]) { return; }

  if (_inputClearsCurrent) {
    [self clearInput];
    _inputClearsCurrent = NO;
  }

  // do we already have a decimal
  if (_inputMode != EWCCalculatorInputModeRegular) { return; }

  _inputMode = EWCCalculatorInputModeFraction;
  _fractionPower = 0;
}

- (void)runState:(EWCCalculatorState)state {
  _state = state;
  [self runState];
}

- (void)runState {
  switch (_state) {
    case EWCCalculatorStartState:
      [self runStartState];
      break;
    case EWCCalculatorReadyState:
      [self runReadyState];
      break;
    case EWCCalculatorCalculatedState:
      [self runCalculatedState];
      break;
    case EWCCalculatorFirstInputState:
      [self runFirstInputState];
      break;
    case EWCCalculatorSecondInputState:
      [self runSecondInputState];
      break;
    case EWCCalculatorOperandState:
      [self runOperandState];
      break;
    case EWCCalculatorCalculatedOperandState:
      [self runOperandState];
      break;
    case EWCCalculatorSecondClearedState:
      [self runSecondClearedState];
      break;
    case EWCCalculatorErrorState:
      [self runErrorState];
      break;
    case EWCCalculatorErrorClearedState:
      [self runErrorClearedState];
      break;
    case EWCCalculatorRateShiftedState:
      [self runRateShiftedState];
      break;
    case EWCCalculatorShowTaxState:
      [self runShowTaxState];
      break;
  }
}

- (BOOL)isDigitKey:(EWCCalculatorKey)key {
  switch (key) {
    case EWCCalculatorZeroKey:
    case EWCCalculatorOneKey:
    case EWCCalculatorTwoKey:
    case EWCCalculatorThreeKey:
    case EWCCalculatorFourKey:
    case EWCCalculatorFiveKey:
    case EWCCalculatorSixKey:
    case EWCCalculatorSevenKey:
    case EWCCalculatorEightKey:
    case EWCCalculatorNineKey:
      return YES;

    default:
      return NO;
  }
}

// return -1 if invalid
- (short)digitFromKey:(EWCCalculatorKey)key {
  switch (key) {
    case EWCCalculatorZeroKey:
      return 0;

    case EWCCalculatorOneKey:
      return 1;

    case EWCCalculatorTwoKey:
      return 2;

    case EWCCalculatorThreeKey:
      return 3;

    case EWCCalculatorFourKey:
      return 4;

    case EWCCalculatorFiveKey:
      return 5;

    case EWCCalculatorSixKey:
      return 6;

    case EWCCalculatorSevenKey:
      return 7;

    case EWCCalculatorEightKey:
      return 8;

    case EWCCalculatorNineKey:
        return 9;

    default:
      return -1;
  }
}

- (BOOL)isBinaryOpKey:(EWCCalculatorKey)key {
  switch (key) {
    case EWCCalculatorAddKey:
    case EWCCalculatorSubtractKey:
    case EWCCalculatorMultiplyKey:
    case EWCCalculatorDivideKey:
      return YES;

    default:
      return NO;
  }
}

- (EWCCalculatorOperator)getOperatorFromKey:(EWCCalculatorKey)key {
  EWCCalculatorOperator op;
  switch (key) {
    case EWCCalculatorAddKey:
      op = EWCCalculatorAddOperator;
      break;

    case EWCCalculatorSubtractKey:
      op = EWCCalculatorSubtractOperator;
      break;

    case EWCCalculatorMultiplyKey:
      op = EWCCalculatorMultiplyOperator;
      break;

    case EWCCalculatorDivideKey:
      op = EWCCalculatorDivideOperator;
      break;

    default:
      op = EWCCalculatorNoOperator;
      break;
  }

  return op;
}

- (void)setOperator {
  EWCCalculatorOperator op = [self getOperatorFromKey:_key];
  if (op == EWCCalculatorNoOperator) {
    [self goToError];
  } else {
    _operator = op;
  }
}

- (void)startInputAndTransitionTo:(EWCCalculatorState)state {
  BOOL ok = YES;

  if ([self isDigitKey:_key] || _key == EWCCalculatorDecimalKey) {
    [self clearInput];
  }

  ok = [self processInput];

  if (ok) {
    [self goToState:state];
  } else {
    [self goToError];
  }
}

// returns NO if error
- (BOOL)processInput {
  if ([self isDigitKey:_key]) {
    short digit = [self digitFromKey:_key];
    if (digit == -1) {
      return NO;
    }
    [self digitPressed:digit];
  } else if (_key == EWCCalculatorSignKey) {
    [self signPressed];
  } else if (_key == EWCCalculatorDecimalKey) {
    [self decimalPressed];
  } else {
    return NO;
  }

  return YES;
}

- (void)goToError {
  [self goToState:EWCCalculatorErrorState];
}

- (BOOL)isInErrorState {
  return _state == EWCCalculatorErrorState;
}

- (void)goToState:(EWCCalculatorState)state {
  _state = state;

  if (_state == EWCCalculatorErrorState) {
    _error = YES;
  }
}

- (void)runStartState {
  [self clearAccumulator];
  [self clearInput];
  [self clearOperand];
  _operator = EWCCalculatorNoOperator;

  _pendingInput = [NSDecimalNumber zero];
  _pendingOperator = EWCCalculatorNoOperator;

  [self runState:EWCCalculatorReadyState];
}

- (void)runReadyState {
  if ([self isDigitKey:_key]) {
    [self startInputAndTransitionTo:EWCCalculatorFirstInputState];
  } else if ([self isBinaryOpKey:_key]) {
    [self copyToAccumulator:_input];
    [self setOperator];
    [self goToState:EWCCalculatorOperandState];
  } else {
    switch (_key) {
      case EWCCalculatorSignKey:
      case EWCCalculatorDecimalKey:
        [self startInputAndTransitionTo:EWCCalculatorFirstInputState];
        break;

      case EWCCalculatorEqualKey:
      case EWCCalculatorClearKey:
      case EWCCalculatorNoKey:
      default:
        ;
    }
  }
}

- (void)runFirstInputState {
  if ([self isDigitKey:_key]) {
    [self processInput];
  } else if ([self isBinaryOpKey:_key]) {
    [self copyToAccumulator:_input];
    [self copyToOperand:_input];
    [self setOperator];
    [self goToState:EWCCalculatorOperandState];
  } else {
    switch (_key) {
      case EWCCalculatorSignKey:
      case EWCCalculatorDecimalKey:
        [self processInput];
        break;

      case EWCCalculatorEqualKey:
        [self copyToAccumulator:_input];
        [self goToState:EWCCalculatorCalculatedState];
        break;

      case EWCCalculatorClearKey:
        _key = EWCCalculatorNoKey;
        [self runState:EWCCalculatorStartState];
        break;

      default:
        ;
    }
  }
}

- (void)runOperandState {
  BOOL ok = YES;

  if ([self isDigitKey:_key]) {
    [self startInputAndTransitionTo:EWCCalculatorSecondInputState];
  } else if ([self isBinaryOpKey:_key]) {
    [self copyToAccumulator:_input];
    [self setOperator];
    // just stay in this state
  } else {
    switch (_key) {
      case EWCCalculatorSignKey:
      case EWCCalculatorDecimalKey:
        [self startInputAndTransitionTo:EWCCalculatorSecondInputState];
        break;

      case EWCCalculatorEqualKey:
        ok = [self performUnaryOperation];
        if (! ok) {
          [self goToError];
          return;
        }
        [self goToState:EWCCalculatorCalculatedState];
        break;

      case EWCCalculatorClearKey:
        _key = EWCCalculatorNoKey;
        [self runState:EWCCalculatorStartState];
        break;

      default:
        ;
    }
  }
}

- (void)runSecondInputState {
  BOOL ok = YES;

  if ([self isDigitKey:_key]) {
    [self processInput];
  } else if ([self isBinaryOpKey:_key]) {
    [self copyToOperand:_input];
    ok = [self performOperation];
    if (! ok) {
      [self goToError];
      return;
    }
    [self copyToInput:_accumulator];
    [self setOperator];
    [self goToState:EWCCalculatorOperandState];
  } else {
    switch (_key) {
      case EWCCalculatorSignKey:
      case EWCCalculatorDecimalKey:
        [self processInput];
        break;

      case EWCCalculatorEqualKey:
        [self copyToOperand:_input];
        ok = [self performOperation];
        if (! ok) {
          [self goToError];
          return;
        }
        [self goToState:EWCCalculatorCalculatedState];
        break;

      case EWCCalculatorClearKey:
        [self clearInput];
        [self runState:EWCCalculatorSecondClearedState];
        break;

      default:
        ;
    }
  }
}

- (void)runSecondClearedState {
  BOOL ok = YES;

  if ([self isDigitKey:_key]) {
    [self startInputAndTransitionTo:EWCCalculatorSecondInputState];
  } else if ([self isBinaryOpKey:_key]) {
    [self copyToAccumulator:_input];
    [self setOperator];
    [self goToState:EWCCalculatorOperandState];
  } else {
    switch (_key) {
      case EWCCalculatorSignKey:
      case EWCCalculatorDecimalKey:
        [self startInputAndTransitionTo:EWCCalculatorSecondInputState];
        break;

      case EWCCalculatorEqualKey:
        [self copyToOperand:_input];
        ok = [self performOperation];
        if (! ok) {
          [self goToError];
          return;
        }
        [self goToState:EWCCalculatorCalculatedState];
        break;

      case EWCCalculatorClearKey:
        _key = EWCCalculatorNoKey;
        [self runState:EWCCalculatorStartState];
        break;

      default:
        ;
    }
  }
}

- (void)runCalculatedState {
  BOOL ok = YES;

  if ([self isDigitKey:_key]) {
    [self startInputAndTransitionTo:EWCCalculatorFirstInputState];
  } else if ([self isBinaryOpKey:_key]) {
    [self copyToInput:_accumulator];
    [self copyToOperand:_input];
    [self setOperator];
    [self goToState:EWCCalculatorOperandState];
  } else {
    switch (_key) {
      case EWCCalculatorDecimalKey:
        [self startInputAndTransitionTo:EWCCalculatorFirstInputState];
        break;

      case EWCCalculatorSignKey:
        [self invertAccumulator];
        // remain in current state
        break;

      case EWCCalculatorEqualKey:
        ok = [self performOperation];
        if (! ok) {
          [self goToError];
          return;
        }
        // remain in current state
        break;

      case EWCCalculatorClearKey:
        _key = EWCCalculatorNoKey;
        [self runState:EWCCalculatorStartState];
        break;

      case EWCCalculatorNoKey:
      default:
        ;
    }
  }
}

- (void)runErrorState {
  // TEMPORARY
  if (_key == EWCCalculatorClearKey) {
    _error = NO;
//    [self copyToAccumulator:_input];
    [self goToState:EWCCalculatorErrorClearedState];
  }
}

- (void)runErrorClearedState {
  if ([self isDigitKey:_key]) {
    [self startInputAndTransitionTo:EWCCalculatorFirstInputState];
  } else if ([self isBinaryOpKey:_key]) {
//    [self copyToAccumulator:_input];
    [self copyToInput:_accumulator];
    [self setOperator];
    [self goToState:EWCCalculatorOperandState];
  } else {
    switch (_key) {
      case EWCCalculatorDecimalKey:
        [self startInputAndTransitionTo:EWCCalculatorFirstInputState];
        break;

      case EWCCalculatorSignKey:
        [self invertAccumulator];
        // remain in current state
        break;

      case EWCCalculatorEqualKey:
        [self copyToAccumulator:_input];
        [self goToState:EWCCalculatorCalculatedState];
        break;

      case EWCCalculatorClearKey:
        _key = EWCCalculatorNoKey;
        [self runState:EWCCalculatorStartState];
        break;

      case EWCCalculatorNoKey:
      default:
        ;
    }
  }
}

- (void)runRateShiftedState {
  switch (_key) {
    case EWCCalculatorTaxPlusKey:
      // when shifted, this is store
      _taxRate = self.displayValue;
      _taxPercentStatusVisible = YES;
      [self goToState:EWCCalculatorShowTaxState];
      break;

    case EWCCalculatorTaxMinusKey:
      // when shifted, this is recall
      self.displayValue = _taxRate;
      _taxPercentStatusVisible = YES;
      [self goToState:EWCCalculatorShowTaxState];
      break;

    default:
      _shift = NO;
      _state = _unshiftState;
      [self runState];
  }
}

- (void)runShowTaxState {
  switch (_key) {
    case EWCCalculatorTaxPlusKey:
      // when shifted, this is store
      _taxRate = self.displayValue;
      break;

    case EWCCalculatorTaxMinusKey:
      // when shifted, this is recall
      self.displayValue = _taxRate;
      break;

    default:
      _shift = NO;
      _state = _unshiftState;
      [self runState];
  }
}

- (void)pressKey:(EWCCalculatorKey)key {
  _key = key;

  if (_key == EWCCalculatorSqrtKey) {
    if (! [self performSqrt]) {
      [self copyToAccumulator:self.displayValue];
      [self goToError];
    }
  } else if (_key == EWCCalculatorRateKey) {
    _shift = ! _shift;
    if (_shift) {
      _unshiftState = _state;
      [self goToState:EWCCalculatorRateShiftedState];
    } else {
      [self runState];
    }
  } else {
    [self runState];
  }

  if (_callback) {
    _callback();
  }
}

@end

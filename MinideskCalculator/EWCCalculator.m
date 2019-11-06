//
//  EWCCalculator.m
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/29/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCCalculator.h"
#import "NSDecimalNumber+EWCMathCategory.h"
#import "EWCNumericField.h"
#import "EWCCalculatorOpcode.h"
#import "EWCCalculatorToken.h"

typedef NS_ENUM(NSInteger, EWCCalculatorInputMode) {
  EWCCalculatorInputModeRegular = 1,
  EWCCalculatorInputModeFraction,
};

@interface EWCCalculator() {
  EWCCalculatorUpdatedCallback _callback;
  BOOL _shift;
  BOOL _error;
  EWCNumericField *_accumulator;
  EWCNumericField *_input;
  EWCNumericField *_display;
  BOOL _editingDisplay;  // NO when user hasn't contributed to input yet
  BOOL _displayAvailable;  // YES if consider display to have useable data
  EWCNumericField *_taxRate;
  EWCNumericField *_memory;
  EWCNumericField *_operand;
  EWCCalculatorOpcode _operation;
  NSNumberFormatter *_formatter;
  EWCCalculatorInputMode _inputMode;
  short _fractionPower;
  short _sign;
  EWCCalculatorKey _key;

  NSMutableArray<EWCCalculatorToken *> *_queue;
  short _ip;
}

@property (nonatomic, getter=isMemoryStatusVisible) BOOL memoryStatusVisible;
@property (nonatomic, getter=isTaxStatusVisible) BOOL taxStatusVisible;
@property (nonatomic, getter=isTaxPlusStatusVisible) BOOL taxPlusStatusVisible;
@property (nonatomic, getter=isTaxMinusStatusVisible) BOOL taxMinusStatusVisible;
@property (nonatomic, getter=isTaxPercentStatusVisible) BOOL taxPercentStatusVisible;

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
  _editingDisplay = YES;

  _taxRate = [EWCNumericField new];
  _memory = [EWCNumericField new];
  _display = [EWCNumericField new];
  _accumulator = [EWCNumericField new];
  _operand = [EWCNumericField new];
  _formatter = [self getFormatter];
  _key = EWCCalculatorNoKey;

  _queue = [NSMutableArray<EWCCalculatorToken *> new];

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

  NSDecimalNumber *value = _display.value;
  NSString *display = [_formatter stringFromNumber:value];

  display = [self processDisplay:display];

  return display;
}

- (void)setDisplayValue:(NSDecimalNumber *)value {
  _display.value = value;
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
  return _error;
}

- (void)fullClear {
  [self clearDisplay];
  [self clearInput];
  [self clearAccumulator];
  [self clearOperand];
  _operation = EWCCalculatorNoOpcode;
}

- (void)clearDisplay {
  [_display clear];
  _inputMode = EWCCalculatorInputModeRegular;
  _fractionPower = 0;
  _sign = 1;
  _formatter.minimumFractionDigits = 0;
  _shift = NO;
  _editingDisplay = NO;
  _displayAvailable = NO;
}

- (void)clearInput {
  [_input clear];
}

- (void)clearAccumulator {
  [_accumulator clear];
}

- (void)clearOperand {
  [_operand clear];
}

- (void)clearTaxRate {
  [_taxRate clear];
}

- (void)clearMemory {
  [_memory clear];
}

- (void)setAccumulator:(NSDecimalNumber *)number {
  _accumulator.value = number;
}

- (void)setOperand:(NSDecimalNumber *)number {
  _operand.value = number;
}

- (void)setInput:(NSDecimalNumber *)number {
  _input.value = number;
}

- (void)setDisplay:(NSDecimalNumber *)number {
  _display.value = number;
  _editingDisplay = NO;
  _displayAvailable = NO;
}

- (void)setTaxRate:(NSDecimalNumber *)number {
  _taxRate.value = number;
}

- (void)setMemory:(NSDecimalNumber *)number {
  _memory.value = number;
}

- (void)addValueToMemory:(NSDecimalNumber *)number {
  _memory.value = [_memory.value decimalNumberByAdding:number];
}

- (void)subtractValueFromMemory:(NSDecimalNumber *)number {
  _memory.value = [_memory.value decimalNumberBySubtracting:number];
}

- (void)digitPressed:(int)digit {
  // no action if in error state
  if (_error) { return; }

  if (! _editingDisplay) {
    [self clearDisplay];
    _editingDisplay = YES;
  }

  _displayAvailable = YES;

  digit *= _sign;

  switch (_inputMode) {
    case EWCCalculatorInputModeRegular: {
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      NSDecimalNumber *tmp = [_display.value decimalNumberByMultiplyingByPowerOf10:1];
      _display.value = [tmp decimalNumberByAdding:decimalDigit];
    }
    break;

    case EWCCalculatorInputModeFraction: {
      _fractionPower--;
      _formatter.minimumFractionDigits = -_fractionPower;
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      decimalDigit = [decimalDigit decimalNumberByMultiplyingByPowerOf10:_fractionPower];
      _display.value = [_display.value decimalNumberByAdding:decimalDigit];
    }
    break;
  }
}

- (void)performBinaryOperation:(EWCCalculatorOpcode)op
  withData:(NSDecimalNumber *)data
  andOperand:(NSDecimalNumber *)operand {

  if (op == EWCCalculatorDivideOpcode
    && [operand isEqualToNumber:@0]) {
    // error
    [self setError];
    return;
  }

  switch (op) {
    case EWCCalculatorAddOpcode:
      [self setAccumulator:[data decimalNumberByAdding:operand]];
      break;

    case EWCCalculatorSubtractOpcode:
      [self setAccumulator:[data decimalNumberBySubtracting:operand]];
      break;

    case EWCCalculatorMultiplyOpcode:
      [self setAccumulator:[data decimalNumberByMultiplyingBy:operand]];
      break;

    case EWCCalculatorDivideOpcode:
      [self setAccumulator:[data decimalNumberByDividingBy:operand]];
      break;

    default:
      [self setError];
      return;
  }

  [self setOperand:operand];
  _operation = op;
  [self setDisplay:_accumulator.value];
}

- (void)performUnaryOperation:(EWCCalculatorOpcode)op
  withData:(NSDecimalNumber *)data {

  switch (op) {
    case EWCCalculatorAddOpcode:
      [self performBinaryOperation:op
        withData:[NSDecimalNumber zero]
        andOperand:data];
      break;

    case EWCCalculatorSubtractOpcode:
      [self performBinaryOperation:op
        withData:[NSDecimalNumber zero]
        andOperand:data];
      break;

    case EWCCalculatorMultiplyOpcode:
      [self performBinaryOperation:op
        withData:data
        andOperand:data];
      break;

    case EWCCalculatorDivideOpcode:
      [self performBinaryOperation:op
        withData:[NSDecimalNumber one]
        andOperand:data];
      break;

    default:
      [self setError];
      return;
  }
}

- (void)signPressed {
  // no action if in error state
  if (_error) { return; }

  if ([_display.value isEqualToNumber:@0]) { return; }

  _displayAvailable = YES;

  _sign = -_sign;

  NSDecimalNumber *minusOne = [[NSDecimalNumber alloc] initWithInt:-1];
  _display.value = [_display.value decimalNumberByMultiplyingBy:minusOne];
}

- (void)sqrtPressed {
  // no action if in error state
  if (_error) { return; }

  [self setDisplay:[_display.value ewc_decimalNumberBySqrt]];
  _displayAvailable = YES;
}

- (void)decimalPressed {
  if (_error) { return; }

  if (! _editingDisplay) {
    [self clearDisplay];
    _editingDisplay = YES;
  }

  _displayAvailable = YES;

  // do we already have a decimal
  if (_inputMode != EWCCalculatorInputModeRegular) { return; }

  _inputMode = EWCCalculatorInputModeFraction;
  _fractionPower = 0;
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
  if (key < EWCCalculatorZeroKey || key > EWCCalculatorNineKey) {
    return -1;
  }

  return (key - EWCCalculatorZeroKey);
}

- (EWCCalculatorOpcode)getOpcodeFromKey:(EWCCalculatorKey)key {
  EWCCalculatorOpcode op;

  switch (key) {
    case EWCCalculatorAddKey:
      op = EWCCalculatorAddOpcode;
      break;

    case EWCCalculatorSubtractKey:
      op = EWCCalculatorSubtractOpcode;
      break;

    case EWCCalculatorMultiplyKey:
      op = EWCCalculatorMultiplyOpcode;
      break;

    case EWCCalculatorDivideKey:
      op = EWCCalculatorDivideOpcode;
      break;

    case EWCCalculatorPercentKey:
      op = EWCCalculatorPercentOpcode;
      break;

    case EWCCalculatorEqualKey:
      op = EWCCalculatorEqualOpcode;
      break;

    default:
      op = EWCCalculatorNoOpcode;
      break;
  }

  return op;
}

// returns NO if key was not handled
- (BOOL)processInputKey:(EWCCalculatorKey)key {
  if ([self isDigitKey:key]) {
    short digit = [self digitFromKey:key];
    if (digit == -1) {
      return NO;
    }
    [self digitPressed:digit];
  } else if (key == EWCCalculatorSignKey) {
    [self signPressed];
  } else if (key == EWCCalculatorDecimalKey) {
    [self decimalPressed];
  } else {
    return NO;
  }

  return YES;
}

- (void)setError {
  _error = YES;
  [_queue removeAllObjects];
  _ip = 0;
}

- (void)performLastOperation {
  NSDecimalNumber *acc = _accumulator.value;
  NSDecimalNumber *opd = _operand.value;
  EWCCalculatorOpcode op = _operation;

  switch (op) {
    case EWCCalculatorAddOpcode:
      acc = [acc decimalNumberByAdding:opd];
      break;

    case EWCCalculatorSubtractOpcode:
      acc = [acc decimalNumberBySubtracting:opd];
      break;

    case EWCCalculatorMultiplyOpcode:
      acc = [acc decimalNumberByMultiplyingBy:opd];
      break;

    case EWCCalculatorDivideOpcode:
      acc = [acc decimalNumberByDividingBy:opd];
      break;

    default:
      // nop
      return;
  }

  [self setAccumulator:acc];
  [self setDisplay:acc];
}

- (BOOL)parseStartingWithOp:(EWCCalculatorToken *)aToken {

  // must be one of
  // o= - change the operator used for last operation (and execute it)
  // od= - binary operation
  // odo - binary operation with a continuation

  BOOL shouldCommit = NO;

  EWCCalculatorToken *o1 = nil, *d1 = nil, *o2 = nil, *eq = nil;
  o1 = aToken;

  d1 = [self nextTokenAs:EWCCalculatorDataTokenType];
  if (! d1) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // o= - change the operator used for last operation (and execute it)
      _operation = o1.opcode;
      [self performLastOperation];
      return YES;
    }

    return NO;
  }

  o2 = [self nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o2) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // od= - binary operation
      NSDecimalNumber *acc = _accumulator.value;
      [self performBinaryOperation:o1.opcode withData:acc andOperand:d1.data];
      return YES;
    }

    return NO;
  }

  // odo - binary operation with a continuation
  NSDecimalNumber *acc = _accumulator.value;
  [self pushbackToken];
  [self performBinaryOperation:o1.opcode withData:acc andOperand:d1.data];

  return shouldCommit;
}

- (BOOL)parseStartingWithData:(EWCCalculatorToken *)aToken {

  // must be one of
  // d= - assign d to acc, and perform last if present
  // do= - unary operation on d
  // dod= - binary operation
  // dodo - binary operation with a continuation

  BOOL shouldCommit = NO;

  EWCCalculatorToken *d1 = nil, *o1 = nil, *d2 = nil, *o2 = nil, *eq = nil;
  d1 = aToken;

  o1 = [self nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o1) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // d= - assign d to acc, and perform last if present
      [self setAccumulator:d1.data];
      if (_operation != EWCCalculatorNoOpcode) {
        [self performLastOperation];
      }
      return YES;
    }

    return NO;
  }

  d2 = [self nextTokenAs:EWCCalculatorDataTokenType];
  if (! d2) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // do= - unary operation on d
      [self performUnaryOperation:o1.opcode withData:d1.data];
      return YES;
    }

    return NO;
  }

  o2 = [self nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o2) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // dod= - binary operation
      [self performBinaryOperation:o1.opcode withData:d1.data andOperand:d2.data];
      return YES;
    }

    return NO;
  }

  // dodo - binary operation with a continuation
  [self pushbackToken];
  [self performBinaryOperation:o1.opcode withData:d1.data andOperand:d2.data];

  return shouldCommit;
}

- (void)parseQueue {

  BOOL shouldCommit = NO;
  _ip = 0;

  EWCCalculatorToken *token = [self nextToken];
  switch (token.tokenType) {
    case EWCCalculatorEmptyTokenType:
      // nothing to do
      return;

    case EWCCalculatorBinOpTokenType:
      // could be continuation op or unary
      shouldCommit = [self parseStartingWithOp:token];
      break;

    case EWCCalculatorEqualTokenType:
      // perform last operation
      [self performLastOperation];
      shouldCommit = YES;
      break;

    case EWCCalculatorDataTokenType:
      // could be start of binary op, or simple assignment
      shouldCommit = [self parseStartingWithData:token];
      break;
  }

  if (shouldCommit) {
    // clear processed items
    [_queue removeObjectsInRange:NSMakeRange(0, _ip)];
    _ip = 0;
  }
}

- (EWCCalculatorToken *)nextTokenAs:(EWCCalculatorTokenType)tokenType {  
  if (_queue.count == 0 || _ip >= _queue.count) { return nil; }

  EWCCalculatorToken *token = _queue[_ip];
  if (token.tokenType == tokenType) {
    ++_ip;
  } else {
    token = nil;
  }

  return token;
}

- (EWCCalculatorToken *)nextToken {
  if (_queue.count == 0 || _ip >= _queue.count) { return nil; }

  EWCCalculatorToken *token = _queue[_ip];
  ++_ip;

  return token;
}

- (void)pushbackToken {
  --_ip;
}

- (void)enqueueBinOp:(EWCCalculatorOpcode)op {

  // if the last item in queue is a binary op, and we are adding a binary op,
  // just replace it (user changed mind about operator)
  BOOL replaced = NO;
  if (_queue.count > 0) {
    EWCCalculatorToken *last = _queue[_queue.count - 1];
    if (last.tokenType == EWCCalculatorBinOpTokenType) {
      _queue[_queue.count - 1] = [EWCCalculatorToken tokenWithBinOp:op];
      replaced = YES;
    }
  }

  if (! replaced) {
    [_queue addObject:[EWCCalculatorToken tokenWithBinOp:op]];
  }

  [self parseQueue];
}

- (void)enqueueData:(NSDecimalNumber *)data {
  [_queue addObject:[EWCCalculatorToken tokenWithData:data]];
  [self parseQueue];
}

- (void)enqueueToken:(EWCCalculatorToken *)token {
  [_queue addObject:token];
  [self parseQueue];
}

- (void)resetAll {
  [self fullClear];
  [_queue removeAllObjects];
}

- (void)processClearKey {
  if (_error) {
    _error = NO;
    return;
  }

  [self resetAll];
}

- (void)runErrorStateWithInput:(EWCCalculatorKey)key {
  if (key == EWCCalculatorClearKey) {
    [self processClearKey];
  }
}

- (BOOL)processKey:(EWCCalculatorKey)key {
  BOOL handled = NO;

  if (_error) {
    [self runErrorStateWithInput:key];
    return YES;
  }

  handled = [self processInputKey:key];
  if (handled) { return handled; }

  if (key == EWCCalculatorSqrtKey) {
    [self sqrtPressed];
    return YES;
  }

  // we pressed a key that doesn't contribute to editing the display
  // so the input is complete

  if (_displayAvailable) {
    _editingDisplay = NO;
    _displayAvailable = NO;
    [self enqueueData:_display.value];
  }

  if (key == EWCCalculatorClearKey) {
    [self processClearKey];
    return YES;
  } else if (EWCCalculatorKeyIsBinaryOp(key)) {
    [self enqueueBinOp:[self getOpcodeFromKey:key]];
  } else if (key == EWCCalculatorEqualKey) {
    [self enqueueToken:[EWCCalculatorToken tokenAsEqual]];
  }

  return handled;
}

- (void)pressKey:(EWCCalculatorKey)key {
  _key = key;

  [self processKey:key];

  if (_callback) {
    _callback();
  }
}

@end

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
#import "EWCCalculatorDataProtocol.h"

typedef NS_ENUM(NSInteger, EWCCalculatorInputMode) {
  EWCCalculatorInputModeRegular = 1,
  EWCCalculatorInputModeFraction,
};

@interface EWCCalculator() {
  EWCCalculatorUpdatedCallback _callback;
  BOOL _shift;
  BOOL _error;
  EWCNumericField *_accumulator;
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
  short _numDigits;
  EWCCalculatorKey _lastKey;
  BOOL _showingJustTax;

  NSDecimalNumber *_taxResultWithTax;
  NSDecimalNumber *_taxResultJustTax;

  NSMutableArray<EWCCalculatorToken *> *_queue;
  short _ip;
}

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
  _taxStatusVisible = NO;
  _taxPlusStatusVisible = NO;
  _taxMinusStatusVisible = NO;
  _taxPercentStatusVisible = NO;

  _maximumDigits = 0;

  _error = NO;

  _editingDisplay = NO;
  _displayAvailable = NO;
  _fractionPower = 0;
  _sign = 1;
  _display = [EWCNumericField new];

  _operation = EWCCalculatorNoOpcode;
  _operand = [EWCNumericField new];

  _accumulator = [EWCNumericField new];

  _shift = NO;
  _taxRate = [EWCNumericField new];
  _memory = [EWCNumericField new];

  _formatter = [self getFormatter];

  _lastKey = EWCCalculatorNoKey;

  _queue = [NSMutableArray<EWCCalculatorToken *> new];
  _ip = 0;

  [self fullClear];
}

- (void)setDataProvider:(id<EWCCalculatorDataProtocol>)dataProvider {
  _dataProvider = dataProvider;

  if (_dataProvider) {
    _taxRate.value = _dataProvider.taxRate;
    [self setMemory:_dataProvider.memory];
  }
}

- (NSNumberFormatter *)getFormatter {
  NSNumberFormatter *formatter = [NSNumberFormatter new];

  formatter.maximumFractionDigits = 20;
  formatter.groupingSize = 3;
  formatter.usesGroupingSeparator = YES;

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

- (NSString *)displayAccessibleContent {

  NSDecimalNumber *value = _display.value;
  NSNumberFormatter *formatter = [self getFormatter];
  [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];

  NSString *display = [formatter stringFromNumber:value];

  display = [self processDisplay:display];

  return display;
}

- (NSString *)processDisplay:(NSString *)display {
  // append decimal if needed
  if (! [display containsString:@"."]) {
    display = [display stringByAppendingString:@"."];
  }

  return display;
}

- (BOOL)isMemoryStatusVisible {
  return ! _memory.empty;
}

// implements public accessor
- (BOOL)isRateShifted {
  return _shift;
}

// implements public accessor
- (BOOL)isErrorStatusVisible {
  return _error;
}

// implements public accessor
- (BOOL)shouldMemoryClear {
  return (_lastKey == EWCCalculatorMemoryKey);
}

- (void)fullClear {
  [self clearDisplay];
  [self clearCalculation];
  _shift = NO;
}

- (void)clearCalculation {
  [self clearAccumulator];
  [self clearOperand];

  _operation = EWCCalculatorNoOpcode;

  [_queue removeAllObjects];
  _ip = 0;
}

- (void)clearDisplay {
  [_display clear];
  _inputMode = EWCCalculatorInputModeRegular;
  _fractionPower = 0;
  _sign = 1;
  _formatter.minimumFractionDigits = 0;
  _numDigits = 0;
  _editingDisplay = NO;
  _displayAvailable = NO;
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

  if (_dataProvider) {
    _dataProvider.memory = _memory.value;
  }
}

- (void)clearAllTaxStatus {
  _taxStatusVisible = NO;
  _taxPlusStatusVisible = NO;
  _taxMinusStatusVisible = NO;
  _taxPercentStatusVisible = NO;
}

- (void)setAccumulator:(NSDecimalNumber *)number {
  _accumulator.value = number;
}

- (void)setOperand:(NSDecimalNumber *)number {
  _operand.value = number;
}

- (NSDecimalNumber *)clampErrorToMaxDigits:(NSDecimalNumber *)number {

  // nothing to do if we aren't clamping
  if (_maximumDigits == 0) {
    return number;
  }

  NSDecimalNumber *maxDigitNumber = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:_maximumDigits isNegative:NO];

  NSDecimalNumber *clamped = nil;
  do {
    number = [number decimalNumberByDividingBy:maxDigitNumber];
    clamped = [number ewc_decimalNumberByRestrictingToDigits:_maximumDigits];
  } while (clamped == nil);

  return clamped;
}

- (void)setDisplay:(NSDecimalNumber *)number {
  [self clearDisplay];

  // restrict number to the registered number of digits
  NSDecimalNumber *clamped = [number ewc_decimalNumberByRestrictingToDigits:_maximumDigits];

  if (! clamped) {
    // precision error
    clamped = [self clampErrorToMaxDigits:number];
    _display.value = clamped;
    [self setError];
  } else {
    _display.value = clamped;
  }
}

- (void)setTaxRate:(NSDecimalNumber *)number {
  _taxRate.value = number;

  if (_dataProvider) {
    _dataProvider.taxRate = number;
  }
}

- (void)setMemory:(NSDecimalNumber *)number {
  // restrict number to the registered number of digits
  NSDecimalNumber *clamped = [number ewc_decimalNumberByRestrictingToDigits:_maximumDigits];

  if (clamped) {
    // number fits
    if ([clamped compare:[NSDecimalNumber zero]] == NSOrderedSame) {
      [self clearMemory];
    } else {
      _memory.value = clamped;

      if (_dataProvider) {
        _dataProvider.memory = clamped;
      }
    }
  } else {
    // precision error, set the value to display, which will trigger error automatically
    [self setDisplay:number];
  }
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

  if (_maximumDigits && (_numDigits + 1 > _maximumDigits)) {
    // don't allow input of more than maximum digits
    return;
  }

  switch (_inputMode) {
    case EWCCalculatorInputModeRegular: {
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      NSDecimalNumber *tmp = [_display.value decimalNumberByMultiplyingByPowerOf10:1];
      _display.value = [tmp decimalNumberByAdding:decimalDigit];
    }
    break;

    case EWCCalculatorInputModeFraction: {
      // if we had no digits, then this is the first, so increment again, as we
      // must have a leading zero
      if (! _numDigits) {
        _numDigits = 1;
      }

      _fractionPower--;
      _formatter.minimumFractionDigits = -_fractionPower;
      NSDecimalNumber *decimalDigit = [[NSDecimalNumber alloc] initWithInt:digit];
      decimalDigit = [decimalDigit decimalNumberByMultiplyingByPowerOf10:_fractionPower];
      _display.value = [_display.value decimalNumberByAdding:decimalDigit];
    }
    break;
  }

  ++_numDigits;
}

- (void)performLastOperation {
  NSDecimalNumber *acc = _accumulator.value;
  NSDecimalNumber *opd = _operand.value;
  EWCCalculatorOpcode op = _operation;

  [self performBinaryOperation:op withData:acc andOperand:opd];
}

- (void)performBinaryOperation:(EWCCalculatorOpcode)op
  withData:(NSDecimalNumber *)data
  andOperand:(NSDecimalNumber *)operand {

  NSDecimalNumber *percent = nil;
  NSDecimalNumber *tmp = nil;
  NSDecimalNumber *hundredth = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:-2 isNegative:NO];

  if ((op == EWCCalculatorDivideOpcode || op == EWCCalculatorDividePercentOpcode)
    && [operand isEqualToNumber:@0]) {
    // error
    [self setError];
    return;
  }

  switch (op) {
    case EWCCalculatorAddOpcode:
      data = [data decimalNumberByAdding:operand];
      break;

    case EWCCalculatorSubtractOpcode:
      data = [data decimalNumberBySubtracting:operand];
      break;

    case EWCCalculatorMultiplyOpcode:
      data = [data decimalNumberByMultiplyingBy:operand];
      break;

    case EWCCalculatorDivideOpcode:
      data = [data decimalNumberByDividingBy:operand];
      break;

    case EWCCalculatorAddPercentOpcode:
      tmp = data;
      percent = [[operand decimalNumberByMultiplyingBy:hundredth] decimalNumberByMultiplyingBy:data];
      data = [data decimalNumberByAdding:percent];
      break;

    case EWCCalculatorSubtractPercentOpcode:
      percent = [[operand decimalNumberByMultiplyingBy:hundredth] decimalNumberByMultiplyingBy:data];
      data = [data decimalNumberBySubtracting:percent];
      break;

    case EWCCalculatorMultiplyPercentOpcode:
      data = [[operand decimalNumberByMultiplyingBy:hundredth] decimalNumberByMultiplyingBy:data];
      break;

    case EWCCalculatorDividePercentOpcode:
      data = [data decimalNumberByDividingBy:[operand decimalNumberByMultiplyingBy:hundredth]];
      break;

    case EWCCalculatorNoOpcode:
      // nop
      break;

    default:
      [self setError];
      return;
  }

  _operation = op;
  [self setAccumulator:data];
  [self setOperand:operand];
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

  BOOL shouldSetError = NO;

  NSDecimalNumber *tmp = _display.value;
  if ([tmp compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
    // negative
    // treat as positive for the sqrt, but riase an error
    tmp = [[NSDecimalNumber zero] decimalNumberBySubtracting:tmp];
    shouldSetError = YES;
  }

  [self setDisplay:[tmp ewc_decimalNumberBySqrt]];
  _displayAvailable = YES;

  if (shouldSetError) {
    [self setError];
  }
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
  [self clearAccumulator];
  [self clearOperand];
  _operation = EWCCalculatorNoOpcode;
}

- (BOOL)parseStartingWithOp:(EWCCalculatorToken *)aToken {

  // must be one of
  // o= - change the operator used for last operation (and execute it)
  // od= - binary operation
  // odo - binary operation with a continuation

  EWCCalculatorToken *o1 = nil, *d1 = nil, *o2 = nil, *eq = nil;
  o1 = aToken;

  d1 = [self nextTokenAs:EWCCalculatorDataTokenType];
  if (! d1) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // o= - change the operator used for last operation (and execute it)
      EWCCalculatorOpcode op = EWCCalculatorOpcodeModifyForEqualMode(o1.opcode, eq.opcode);
      _operation = op;
      //_operation = o1.opcode;
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
      EWCCalculatorOpcode op = EWCCalculatorOpcodeModifyForEqualMode(o1.opcode, eq.opcode);
      [self performBinaryOperation:op withData:acc andOperand:d1.data];
//      [self performBinaryOperation:o1.opcode withData:acc andOperand:d1.data];
      return YES;
    }

    return NO;
  }

  // odo - binary operation with a continuation
  NSDecimalNumber *acc = _accumulator.value;
  [self pushbackToken];
  [self performBinaryOperation:o1.opcode withData:acc andOperand:d1.data];

  return YES;
}

- (BOOL)parseStartingWithData:(EWCCalculatorToken *)aToken {

  // must be one of
  // d= - assign d to acc, and perform last if present
  // do= - unary operation on d
  // dod= - binary operation
  // dodo - binary operation with a continuation

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
      // do= - unary operation on d, but not for percent
      if (eq.opcode == EWCCalculatorEqualOpcode) {
        [self performUnaryOperation:o1.opcode withData:d1.data];
      }

      // regardless, advance the queue
      return YES;
    }

    return NO;
  }

  o2 = [self nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o2) {
    eq = [self nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // dod= - binary operation
      EWCCalculatorOpcode op = EWCCalculatorOpcodeModifyForEqualMode(o1.opcode, eq.opcode);
      [self performBinaryOperation:op withData:d1.data andOperand:d2.data];
      return YES;
    }

    return NO;
  }

  // dodo - binary operation with a continuation
  [self pushbackToken];
  [self performBinaryOperation:o1.opcode withData:d1.data andOperand:d2.data];

  return YES;
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
      // perform last operation (only if normal equal)
      if (token.opcode == EWCCalculatorEqualOpcode) {
        [self performLastOperation];
      }

      // but clear the queue regardless
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

- (void)enqueueEqual:(EWCCalculatorOpcode)op {

  // should not allow back to back equal tokens
  // they get removed due to processing, so a back to back equal is strange
  if (_queue.count > 0) {
    EWCCalculatorToken *last = _queue[_queue.count - 1];
    if (last.tokenType == EWCCalculatorEqualTokenType) {
      [self setError];
      return;
    }
  }

  [_queue addObject:[EWCCalculatorToken tokenWithEqual:op]];
  [self parseQueue];
}

- (void)enqueueData:(NSDecimalNumber *)data {

  // if the last item in queue is data, and we are adding data,
  // just replace it (user could have been working with memory or rate)
  BOOL replaced = NO;
  if (_queue.count > 0) {
    EWCCalculatorToken *last = _queue[_queue.count - 1];
    if (last.tokenType == EWCCalculatorDataTokenType) {
      _queue[_queue.count - 1] = [EWCCalculatorToken tokenWithData:data];
      replaced = YES;
    }
  }

  if (! replaced) {
    [_queue addObject:[EWCCalculatorToken tokenWithData:data]];
  }

  [self parseQueue];
}

- (void)enqueueToken:(EWCCalculatorToken *)token {
  [_queue addObject:token];
  [self parseQueue];
}

- (void)processClearKey {
  if (_error) {
    _error = NO;
    [self clearAllTaxStatus];
    return;
  }

  [self fullClear];
}

- (void)processMemoryKey {
  _editingDisplay = NO;

  if (_lastKey == EWCCalculatorMemoryKey) {
    // clear memory
    [self clearMemory];
  } else {
    // recall memory
    [self setDisplay:_memory.value];
    _displayAvailable = YES;
  }
}

- (void)processMemoryPlusKey {
  _editingDisplay = NO;

  NSDecimalNumber *mem = _memory.value;
  NSDecimalNumber *opd = _display.value;
  mem = [mem decimalNumberByAdding:opd];

  [self setMemory:mem];
}

- (void)processMemoryMinusKey {
  _editingDisplay = NO;

  NSDecimalNumber *mem = _memory.value;
  NSDecimalNumber *opd = _display.value;
  mem = [mem decimalNumberBySubtracting:opd];

  [self setMemory:mem];
}

- (void)processRateKey {
  _shift = ! _shift;
  _editingDisplay = NO;
}

- (void)displayTaxResult {
  NSDecimalNumber *value;

  if (_showingJustTax) {
    value = _taxResultJustTax;
  } else {
    value = _taxResultWithTax;
  }

  [self setDisplay:value];
//  [self setAccumulator:value];
  _displayAvailable = YES;
}

- (void)processTaxPlusKey {
  if (_shift) {
    // treat as store
    [self setTaxRate:_display.value];
    _taxPercentStatusVisible = YES;
    [self clearCalculation];
  } else {
    // treat as tax plus
    if (_lastKey != EWCCalculatorTaxPlusKey) {
      // first press, so do the calculation and show the summed result
      _showingJustTax = NO;
      _taxPlusStatusVisible = YES;

      NSDecimalNumber *hundredth = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:-2 isNegative:NO];
      NSDecimalNumber *mult = [_taxRate.value decimalNumberByMultiplyingBy:hundredth];
      NSDecimalNumber *tax = [_display.value decimalNumberByMultiplyingBy:mult];
      NSDecimalNumber *tmp = [_display.value decimalNumberByAdding:tax];

      _taxResultWithTax = tmp;
      _taxResultJustTax = tax;

    } else {
      _showingJustTax = ! _showingJustTax;

      // use the cached tax result and show the appropriate part
      if (_showingJustTax) {
        _taxStatusVisible = YES;
      } else {
        _taxPlusStatusVisible = YES;
      }
    }

    [self displayTaxResult];
  }
}

- (void)processTaxMinusKey {
  if (_shift) {
    // treat as recall
    [self setDisplay:_taxRate.value];
    _taxPercentStatusVisible = YES;
    [self clearCalculation];
  } else {
    // treat as tax minus
    if (_lastKey != EWCCalculatorTaxMinusKey) {
      // first press, so do the calculation and show the difference result
      _showingJustTax = NO;
      _taxMinusStatusVisible = YES;

      NSDecimalNumber *hundredth = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:-2 isNegative:NO];
      NSDecimalNumber *mult = [_taxRate.value decimalNumberByMultiplyingBy:hundredth];
      mult = [mult decimalNumberByAdding:[NSDecimalNumber one]];

      if ([mult compare:[NSDecimalNumber zero]] != NSOrderedSame) {
        NSDecimalNumber *tmp = [_display.value decimalNumberByDividingBy:mult];
        NSDecimalNumber *tax = [_display.value decimalNumberBySubtracting:tmp];

        _taxResultWithTax = tmp;
        _taxResultJustTax = tax;

      } else {
        [self setError];
      }

    } else {
      _showingJustTax = ! _showingJustTax;

      // use the cached tax result and show the appropriate part
      if (_showingJustTax) {
        _taxStatusVisible = YES;
      } else {
        _taxMinusStatusVisible = YES;
      }
    }

    if (! _error) {
      [self displayTaxResult];
    }
  }
}

- (void)processInputForErrorState:(EWCCalculatorKey)key {
  if (key == EWCCalculatorClearKey) {
    [self processClearKey];
  }
}

- (void)processKey:(EWCCalculatorKey)key {
  BOOL handled = NO;
  BOOL isRateKey = EWCCalculatorKeyIsRateKey(key);

  if (_error) {
    [self processInputForErrorState:key];
    return;
  }

  // any key clears the tax-related status displays
  [self clearAllTaxStatus];

  // if not a tax rate-related key, unshift
  if (! isRateKey) {
    _shift = NO;
  }

  handled = [self processInputKey:key];
  if (handled) { return; }

  if (key == EWCCalculatorSqrtKey) {
    [self sqrtPressed];
    return;
  } else if (key == EWCCalculatorRateKey) {
    [self processRateKey];
    return;
  } else if (key == EWCCalculatorTaxPlusKey) {
    [self processTaxPlusKey];
    return;
  } else if (key == EWCCalculatorTaxMinusKey) {
    [self processTaxMinusKey];
    return;
  } else if (key == EWCCalculatorMemoryKey) {
    [self processMemoryKey];
    return;
  } else if (key == EWCCalculatorMemoryPlusKey) {
    [self processMemoryPlusKey];
    return;
  } else if (key == EWCCalculatorMemoryMinusKey) {
    [self processMemoryMinusKey];
    return;
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
  } else if (EWCCalculatorKeyIsBinaryOp(key)) {
    [self enqueueBinOp:[self getOpcodeFromKey:key]];
  } else if (key == EWCCalculatorEqualKey) {
    [self enqueueEqual:EWCCalculatorEqualOpcode];
  } else if (key == EWCCalculatorPercentKey) {
    [self enqueueEqual:EWCCalculatorPercentOpcode];
  }
}

- (void)pressKey:(EWCCalculatorKey)key {

  [self processKey:key];

  _lastKey = key;

  if (_callback) {
    _callback();
  }
}

@end

//
//  EWCCalculator.m
//  HomeCalculator
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

#import "EWCCalculator.h"
#import "NSDecimalNumber+EWCMathCategory.h"
#import "EWCNumericField.h"
#import "EWCCalculatorOpcode.h"
#import "EWCCalculatorToken.h"
#import "EWCCalculatorDataProtocol.h"
#import "EWCTokenQueue.h"
#import "EWCDecimalInputBuilder.h"

@interface EWCCalculator() {
  EWCCalculatorUpdatedCallback _callback;  // callback used to notify a listener of state changes in the calculator
  EWCNumericField *_accumulator;  // stores the results of the last calculation
  EWCNumericField *_display;  // stores the value displayed to the client
  EWCNumericField *_taxRate;  // stores the tax rate
  EWCNumericField *_memory;  // stores the general memory value
  EWCNumericField *_operand;  // stores the last operand for binary operations
  EWCCalculatorOpcode _operation;  // stores the last operation
  EWCCalculatorKey _lastKey;  // the last key pressed
  BOOL _showingJustTax;  // whether the display is showing the tax portion of a tax calculation

  BOOL _displayAvailable;  // whether the value held in the display should be considered available for a calculation

  NSDecimalNumber *_taxResultWithTax;  // cache the last tax calculation that includes tax
  NSDecimalNumber *_taxResultJustTax;  // cache the tax from the last tax calculation

  EWCTokenQueue *_tokenQueue;  // queue of tokens the calculator will use to detect valid calculations
  EWCDecimalInputBuilder *_inputBuilder;  // helper class to build up a decimal value from input keys
}

@end

// the default number of rounding fractional digits
const static int s_maximumFractionDigits = 20;

@implementation EWCCalculator

///----------------------------------------------
/// @name Construction and Initialization Methods
///----------------------------------------------

+ (instancetype)calculator {
  return [EWCCalculator new];
}

/**
  Implementation of the empty init method.

  @return The initialized instance.
 */
- (instancetype)init {
  self = [super init];
  if (self) {
    [self sharedInit];
  }

  return self;
}

/**
  Initialization helper method.  Sets state to reasonable defaults and initializes token queue.
 */
- (void)sharedInit {
  _taxStatusVisible = NO;
  _taxPlusStatusVisible = NO;
  _taxMinusStatusVisible = NO;
  _taxPercentStatusVisible = NO;

  _maximumDigits = 0;

  _error = NO;

  _display = [EWCNumericField new];
  _displayAvailable = NO;

  // this property should *not* be read directly from anywhere else but the
  // public property after this, so that it can get a default value if not set
  _locale = nil;

  _operation = EWCCalculatorNoOpcode;
  _operand = [EWCNumericField new];

  _accumulator = [EWCNumericField new];

  _rateShifted = NO;
  _taxRate = [EWCNumericField new];
  _memory = [EWCNumericField new];

  _lastKey = EWCCalculatorNoKey;

  _tokenQueue = [EWCTokenQueue new];
  _inputBuilder = [EWCDecimalInputBuilder new];
  _inputBuilder.maximumDigits = _maximumDigits;

  // clear out all input and calculation status to be ready for user input
  [self fullClear];
}

///------------------------------
/// @name Custom Property Methods
///------------------------------

/**
  Reads and sets the state for values provided by the data provider when set.

  @param dataProvider The provider to use for persistence.
 */
- (void)setDataProvider:(id<EWCCalculatorDataProtocol>)dataProvider {
  _dataProvider = dataProvider;

  if (_dataProvider) {
    _taxRate.value = _dataProvider.taxRate;
    [self setMemory:_dataProvider.memory];
  }
}

/**
  Returns the set locale, using the current locale if it hasn't been set.

  @note The locale value must only be accessed through this property (no direct ivar access) so that it can be given a default value on first access if not set.

  @return The set locale, or the current locale if not already set.
 */
- (NSLocale *)locale {
  if (! _locale) {
    _locale = [[NSLocale currentLocale] copy];
  }

  return _locale;
}

- (NSDecimalNumber *)displayValue {
  // instead of a backing property, return from the display field
  return _display.value;
}

- (BOOL)hasMemory {
  // instead of a backing property, returns based on the content state of the
  // memory field
  return ! _memory.isEmpty;
}

- (BOOL)shouldMemoryClear {
  // if the last key was mrc, then if it is pressed it will be clear
  return (_lastKey == EWCCalculatorMemoryKey);
}

- (void)setMaximumDigits:(NSInteger)value {
  _maximumDigits = value;
  _inputBuilder.maximumDigits = value;
}

- (NSString *)displayContent {

  NSDecimalNumber *value = _display.value;
  NSString *display = [[self getFormatter] stringFromNumber:value];

  display = [self postProcessDisplay:display];

  return display;
}

- (NSString *)displayAccessibleContent {

  NSDecimalNumber *value = _display.value;
  NSNumberFormatter * formatter = [self getAccessibleFormatter];

  NSString *display = [formatter stringFromNumber:value];

  return display;
}

///--------------------------------
/// @name Shared Formatting Methods
///--------------------------------

/**
  Gets a formatter suitable for displaying numbers in the display.

  @return A formatter to be used to format the display value.
 */
- (NSNumberFormatter *)getFormatter {
  NSNumberFormatter *formatter = [NSNumberFormatter new];

  formatter.maximumFractionDigits = (_maximumDigits > 0)
    ? _maximumDigits
    : s_maximumFractionDigits;

  // force at least the number of input fractional digits so that trailing
  // zeros aren't hidden
  formatter.minimumFractionDigits = _inputBuilder.fractionalDigitCount;

  // apply the locale
  formatter.locale = self.locale;

  // This is to be a decimal number display
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

  return formatter;
}

/**
  Gets a formatter suitable for generating the accessibility label for the display

  @return A formatter to be used to format the display accessibility label.
 */
- (NSNumberFormatter *)getAccessibleFormatter {
  // start with our per-locale decimal formatter
  NSNumberFormatter *formatter = [self getFormatter];

  // use a number spell out style so the generated text reads long numbers as
  // the full number and not just a long string of digits
  [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];

  return formatter;
}

///---------------------------------------------------------------
/// @name Public Properties and Methods (documented in the header)
///---------------------------------------------------------------

- (void)registerUpdateCallbackWithBlock:(EWCCalculatorUpdatedCallback)callback {
  // copy the block, in case it was stack allocated
  _callback = [callback copy];
}

/**
  This method is only intended for the client to be able to explicitly set the input without typing keys one by one.

  @note This is not intended to be used within the calculator itself.  Setting this does raise a change notification, but the caller knows that it has made this call, and hence can also perform its update logic.
 */
- (void)setInput:(NSDecimalNumber *)value {
  [self setDisplay:value];
  _displayAvailable = YES;
}

- (void)pressKey:(EWCCalculatorKey)key {

  [self processKey:key];

  _lastKey = key;

  [self safeCallback];
}

///---------------------------------
/// @name Display Processing Methods
///---------------------------------

/**
  Performs final formatting of the diplay string as it is read out by a client.

  The string passed in has already been decimal formatted for the appropriate locale.  This step ensures that it always contains a decimal separator, even if there are no trailing fractional digits.

  @param display The decimal formatted string value of the display.

  @return The display string with a decimal separator if needed.
 */
- (NSString *)postProcessDisplay:(NSString *)display {
  NSString *separator = [self.locale decimalSeparator];

  // append decimal separator if needed
  if (! [display containsString:separator]) {
    display = [display stringByAppendingString:separator];
  }

  return display;
}

/**
  Clears the display and input builder state.
 */
- (void)clearDisplay {
  [_display clear];
  [_inputBuilder clear];
}

/**
  Sets the value to be shown in the display.

  This also resets the input builder state.

  @note The calculator may enter the error state if the number being set cannot fit within the maximum number of allowed digits.

  @param number The number to show in the display.
*/
- (void)setDisplay:(NSDecimalNumber *)number {
  [self clearDisplay];

  // restrict number to the registered number of digits
  NSDecimalNumber *clamped = [number ewc_decimalNumberByRestrictingToDigits:_maximumDigits];

  if (! clamped) {
    // precision error
    clamped = [self forceClampToMaxDigits:number];
    [self setError];
  }

  _display.value = clamped;

  // the input builder needs to get set along with the display in case
  // there is a sign change after a previous calculation
  _inputBuilder.value = clamped;
}

///-------------------------------------
/// @name Accumulator Processing Methods
///-------------------------------------

/**
  Clears the value in the accumulator.
*/
- (void)clearAccumulator {
  [_accumulator clear];
}

/**
  Sets the value of the accumulator to used in future chained binary operations.

  @param number The number to store in the accumulator.
*/
- (void)setAccumulator:(NSDecimalNumber *)number {
  _accumulator.value = number;
}

///---------------------------------
/// @name Operand Processing Methods
///---------------------------------

/**
  Clears the saved operand.
*/
- (void)clearOperand {
  [_operand clear];
}

/**
  Sets the value of the operand to used in future chained binary operations.

  @param number The number to store as the operand.
 */
- (void)setOperand:(NSDecimalNumber *)number {
  _operand.value = number;
}

///---------------------------------
/// @name Tax Rate Processing Methods
///---------------------------------

/**
  Clears the stored tax rate.
 */
- (void)clearTaxRate {
  [_taxRate clear];
}

/**
  Sets the tax rate to use for tax calulations.

  This cannot result in an error, since the input must have come from the display, which would already have caused an error if a value didn't fit.

  @param number The number to store as the tax rate.
 */
- (void)setTaxRate:(NSDecimalNumber *)number {
  _taxRate.value = number;

  if (_dataProvider) {
    _dataProvider.taxRate = number;
  }
}

///---------------------------------
/// @name Memory Processing Methods
///---------------------------------

/**
  Clears the general memory.
 */
- (void)clearMemory {
  [_memory clear];

  if (_dataProvider) {
    _dataProvider.memory = _memory.value;
  }
}

/**
  Sets the general memory value to the supplied number.

  @note The calculator may enter the error state if the number being set cannot fit within the maximum number of allowed digits.

  @param number The number to store in memory.
 */
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

///-------------------------------------------------
/// @name Other Methods for Clearing/Resetting State
///-------------------------------------------------

/**
  Clears all user input and state related to ongoing calculation.
 */
- (void)fullClear {
  [self clearDisplay];
  [self clearCalculation];
  _rateShifted = NO;
}

/**
  Clears all the state related to an ongoing calculation.
 */
- (void)clearCalculation {
  [self clearAccumulator];
  [self clearOperand];

  _operation = EWCCalculatorNoOpcode;

  [_tokenQueue clear];
}

/**
  Turns of all of the status indicators related to tax calculations.
 */
- (void)clearAllTaxStatus {
  _taxStatusVisible = NO;
  _taxPlusStatusVisible = NO;
  _taxMinusStatusVisible = NO;
  _taxPercentStatusVisible = NO;
}


///-------------------------------------
/// @name Display-only Operation Methods
///-------------------------------------

/**
  Performs a square root on the current display value.

  This is not a chainiable operation, and does not take part in the usual binary operation flow.  The equal key will not repeat this operation, and instead would apply the resulting root to whatever calculation was in progress.

  @note The calculator may enter an error state if the displayed value (the input) is negative.  In that case, the root will still be taken as though it were positive, but the error status will be set.
 */
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

///-----------------------------
/// @name Math Operation Methods
///-----------------------------

/**
  Converts the input operation to an opcode.

  @param key The user input key.

  @return The operation that corresponds to the input key.
 */
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

/**
  Repeats the previous operation.

  Used when the user inputs a bare equal key to repeat the last operation.
 */
- (void)performLastOperation {
  NSDecimalNumber *acc = _accumulator.value;
  NSDecimalNumber *opd = _operand.value;
  EWCCalculatorOpcode op = _operation;

  [self performBinaryOperation:op withData:acc andOperand:opd];
}

/**
  Performs a binary operation.

  The operations are laregly as expected.  The percent operations become enqueued by performing a calculation and using the percent key in place of the equal key.

  @note The calculator can enter an error state by trying to divide by zero (op is onw of the two divide operations and operand is 0).

  @param op The operation to perform.
  @param data The first value in the binary operation.
  @param operand The second value in the binary operation.  Notably, for division, this is the divisor.
 */
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

/**
  Performs a unary operation in response to the user entering something like "3+=".

  For add and subtract, the unary operation acts like adding or subtracting the data value to or from zero.  For multiply, it multiplies with itself, acting like a square operation.  For divide, it divides into one, acting like a reciprocal function.

  The unary operations are effectively implemented as binary operations, allowing subsequent applications of the equal key to continue the operation chain.

  @param op The operation to perform.
  @param data The value to use for the unary operation.
 */
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

///-----------------------------------------
/// @name Other Input Key Processing Methods
///-----------------------------------------

/**
  Process the clear key.

  In an error state, this clears the error.  If the user just edited a value (resulting in that value being the final data item in the queue), just clear out the data value.  Otherwise, clear the entire calculator state back to defaults.
 */
- (void)processClearKey {
  if (_error) {
    _error = NO;
    [self clearAllTaxStatus];
    return;
  }

  // if we are in the middle of a calculation (last token is number)
  // just remove it
  EWCCalculatorToken *lastToken = [_tokenQueue getLastToken];
  if (lastToken && lastToken.tokenType == EWCCalculatorDataTokenType) {
    [_tokenQueue removeLastToken];
    [self clearDisplay];
    return;
  }

  // otherwise, terminate operation
  [self fullClear];
}

/**
  Handles the memory key.

  In isolation, this acts as a memory recall function, but if the last button pressed was the memory key, pressing it again will clear the stored memory value.
 */
- (void)processMemoryKey {
  if (_lastKey == EWCCalculatorMemoryKey) {
    // clear memory
    [self clearMemory];
  } else {
    // recall memory
    [self setDisplay:_memory.value];
    _displayAvailable = YES;
  }
}

/**
  Adds the current value to the stored memory value.
 */
- (void)processMemoryPlusKey {
  NSDecimalNumber *mem = _memory.value;
  NSDecimalNumber *opd = _display.value;
  mem = [mem decimalNumberByAdding:opd];

  [self setMemory:mem];
}

/**
  Subtracts the current value from the stored memory value.

  @note The calculator can enter an error state if the subtraction would result in a value to large to fit in the maximum allowed digits.
 */
- (void)processMemoryMinusKey {
  NSDecimalNumber *mem = _memory.value;
  NSDecimalNumber *opd = _display.value;
  mem = [mem decimalNumberBySubtracting:opd];

  [self setMemory:mem];
}

/**
  Toggles the rate shifted state for setting or recalling the tax rate.
 */
- (void)processRateKey {
  _rateShifted = ! _rateShifted;
}

/**
  Updates the display with one of hte results from the previous tax adjustment calculation.

  It will either show the adjusted result, or just the tax component.  This method doesn't know whether the previous calculation was a plus or minus, so it is still up to the caller to update the relevant status indicators.
 */
- (void)displayTaxResult {
  NSDecimalNumber *value;

  if (_showingJustTax) {
    value = _taxResultJustTax;
  } else {
    value = _taxResultWithTax;
  }

  [self setDisplay:value];
  _displayAvailable = YES;
}

/**
  Processes the tax plus key.

  The key has several possible actions.  In the shifted state, it is used to set the saved tax rate.  When not shifted, it will calculate the tax adjusted value.  Subsequent presses will toggle between showing the adjusted result, and showing the amount of tax that was added.
 */
- (void)processTaxPlusKey {
  if (_rateShifted) {
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

/**
  Processes the tax minus key.

  The key has several possible actions.  In the shifted state, it is used to recall the saved tax rate.  When not shifted, it will deduct tax from the current value.  Subsequent presses will toggle between showing the deducted result, and showing the amount of tax that was deducted.
 */
- (void)processTaxMinusKey {
  if (_rateShifted) {
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

/**
  Process key input when the calculator is in an error state.  The only valid user action is to press the clear key.

  @param key The user input key.
 */
- (void)processInputForErrorState:(EWCCalculatorKey)key {
  if (key == EWCCalculatorClearKey) {
    [self processClearKey];
  }
}

/**
  Process an input key, setting all appropriate states.

  @parama key The user input key.
 */
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
    _rateShifted = NO;
  }

  // keys that contribute to building up a number
  handled = [_inputBuilder processKey:key];
  if (handled) {
    // update the display with the current input
    _display.value = _inputBuilder.value;
    _displayAvailable = YES;
    return;
  }

  // keys that operate on the display value
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
    _displayAvailable = NO;
    [_tokenQueue enqueueData:_display.value];
  }

  if (key == EWCCalculatorClearKey) {
    [self processClearKey];
  } else if (EWCCalculatorKeyIsBinaryOp(key)) {
    [_tokenQueue enqueueBinOp:[self getOpcodeFromKey:key]];
  } else if (key == EWCCalculatorEqualKey) {
    [_tokenQueue enqueueEqual:EWCCalculatorEqualOpcode];
  } else if (key == EWCCalculatorPercentKey) {
    [_tokenQueue enqueueEqual:EWCCalculatorPercentOpcode];
  }

  // check whether one of the previous possible enqueue statements was invalid
  if (_tokenQueue.hasError) {
    [self setError];
    return;
  }

  // if there was a change to the queue, try to parse it
  if (_tokenQueue.didChange) {
    [self parseQueue];
  }
}

///------------------------------
/// @name Operation Queue Methods
///------------------------------

/**
  Parses the operation queue knowing that the first token is an operator.  Knowing this restricts the possible valid operation combinations, making the parsing a little easier.

  @param aToken The operation token that started the operation queue.

  @return YES if the tokens processed during parsing should be removed from the queue (they have been applied to the calculation), otherwise NO (there wasn't yet a complete operation).
 */
- (BOOL)parseStartingWithOp:(EWCCalculatorToken *)aToken {

  // must be one of
  // o= - change the operator used for last operation (and execute it)
  // od= - binary operation
  // odo - binary operation with a continuation

  EWCCalculatorToken *o1 = nil, *d1 = nil, *o2 = nil, *eq = nil;
  o1 = aToken;

  d1 = [_tokenQueue nextTokenAs:EWCCalculatorDataTokenType];
  if (! d1) {
    eq = [_tokenQueue nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // o= - change the operator used for last operation (and execute it)
      EWCCalculatorOpcode op = EWCCalculatorOpcodeModifyForEqualMode(o1.opcode, eq.opcode);
      _operation = op;
      [self performLastOperation];
      return YES;
    }

    return NO;
  }

  o2 = [_tokenQueue nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o2) {
    eq = [_tokenQueue nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // od= - binary operation
      NSDecimalNumber *acc = _accumulator.value;
      EWCCalculatorOpcode op = EWCCalculatorOpcodeModifyForEqualMode(o1.opcode, eq.opcode);
      [self performBinaryOperation:op withData:acc andOperand:d1.data];
      return YES;
    }

    return NO;
  }

  // odo - binary operation with a continuation
  NSDecimalNumber *acc = _accumulator.value;
  [_tokenQueue pushbackToken];
  [self performBinaryOperation:o1.opcode withData:acc andOperand:d1.data];

  return YES;
}

/**
  Parses the operation queue knowing that the first token is data.  Knowing this restricts the possible valid operation combinations, making the parsing a little easier.

  @param aToken The data token that started the operation queue.

  @return YES if the tokens processed during parsing should be removed from the queue (they have been applied to the calculation), otherwise NO (there wasn't yet a complete operation).
 */
- (BOOL)parseStartingWithData:(EWCCalculatorToken *)aToken {

  // must be one of
  // d= - if there was a last operation, assign d to acc and execute, if not this has no real impact on the state, so just consume
  // do= - unary operation on d
  // dod= - binary operation
  // dodo - binary operation with a continuation

  EWCCalculatorToken *d1 = nil, *o1 = nil, *d2 = nil, *o2 = nil, *eq = nil;
  d1 = aToken;

  o1 = [_tokenQueue nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o1) {
    eq = [_tokenQueue nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // d= - if there is a last op, assign d to acc, and perform it (not if percent!)
      if (_operation != EWCCalculatorNoOpcode && eq.opcode == EWCCalculatorEqualOpcode) {
        [self setAccumulator:d1.data];
        [self performLastOperation];
      } else {
        // there was no operation, user just entered a number and hit enter
        // just don't clear the display, mark the that it is available, and let
        // the queue be cleared
        _displayAvailable = YES;
      }
      return YES;
    }

    return NO;
  }

  d2 = [_tokenQueue nextTokenAs:EWCCalculatorDataTokenType];
  if (! d2) {
    eq = [_tokenQueue nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // do= - unary operation on d
      if (eq.opcode == EWCCalculatorEqualOpcode) {
        [self performUnaryOperation:o1.opcode withData:d1.data];
        return YES;
      } else {
        // the equal was a percent, which has no effect
        // leave the queue alone, but excise the percent token
        [_tokenQueue pushbackToken];  // percent is top of queue
        [_tokenQueue popToken];
      }
    }

    return NO;
  }

  o2 = [_tokenQueue nextTokenAs:EWCCalculatorBinOpTokenType];
  if (! o2) {
    eq = [_tokenQueue nextTokenAs:EWCCalculatorEqualTokenType];
    if (eq) {
      // dod= - binary operation
      EWCCalculatorOpcode op = EWCCalculatorOpcodeModifyForEqualMode(o1.opcode, eq.opcode);
      [self performBinaryOperation:op withData:d1.data andOperand:d2.data];
      return YES;
    }

    return NO;
  }

  // dodo - binary operation with a continuation
  [_tokenQueue pushbackToken];
  [self performBinaryOperation:o1.opcode withData:d1.data andOperand:d2.data];

  return YES;
}

/**
  Parses the pending operation queue, looking for an operation that can be performed.

  This method determines roughly how the queu starts, and uses that to delegate handling of the remainder of the parse to helper methods.

  After execution, if a valid oepration was found, the tokens in the operation will be removed from the queue.  If no valid operation is found, the queue will remain unchanged.
 */
- (void)parseQueue {

  // assume that we won't find anything
  BOOL shouldCommit = NO;

  [_tokenQueue moveToFirst];

  // read tokens until either we get passed any empty tokens, or we run out of
  // tokens to process
  EWCCalculatorToken *token = [_tokenQueue nextToken];

  // check whether anything is queued
  if (! token) {
    // nothing in the queue
    return;
  }

  switch (token.tokenType) {
    case EWCCalculatorBinOpTokenType:
      // could be continuation op or unary
      shouldCommit = [self parseStartingWithOp:token];
      break;

    case EWCCalculatorEqualTokenType:
      // perform last operation (only if normal equal)
      if (token.opcode == EWCCalculatorEqualOpcode) {
        [self performLastOperation];
      }

      // but clear the queue regardless (so percent will essentially be a no-op)
      shouldCommit = YES;
      break;

    case EWCCalculatorDataTokenType:
      // could be start of binary op, or simple assignment
      shouldCommit = [self parseStartingWithData:token];
      break;

    case EWCCalculatorEmptyTokenType:
      // nop, just here for enumeration completeness
      // there is no method to enqueue an empty token, so this can never occur
      return;
  }

  // we handled an operation, so commit the portion of the queue that we used.
  if (shouldCommit) {
    // clear processed items
    [_tokenQueue commit];
  }
}

///-----------------------------
/// @name Error Handling Methods
///-----------------------------

/**
  Forcibly clamp a value to the configured number of digits even if it doesn't fit.  This is accomplished by continually dividing it down until it does, using a number based on the max digits so that it doesn't take many iterations.

  @note The resulting number is meaningless.  Only use it dor display in error conditions.

  @param number The number to force clamp (it was probably a number resulting from a calculation which is too large to fit in our allowed number of digits).

  @return A number clamped small enough to fit in the digits.  Effectively, it should contain the most significant digits of the original number, but the decimal will be shifted too far left.
 */
- (NSDecimalNumber *)forceClampToMaxDigits:(NSDecimalNumber *)number {

  // nothing to do if we aren't clamping
  if (_maximumDigits == 0) {
    return number;
  }

  // our divisor is a power of ten related to our max digits.  This effectively
  // will move the decimal max digit positions to the left with each division.
  NSDecimalNumber *maxDigitNumber = [NSDecimalNumber
    decimalNumberWithMantissa:1
    exponent:_maximumDigits
    isNegative:NO];

  NSDecimalNumber *clamped = nil;
  do {
    // divide through until the regular clamp function can successfully clamp
    // the value.  Really this should only take a single pass, but we loop for
    // safety.

    number = [number decimalNumberByDividingBy:maxDigitNumber];
    clamped = [number ewc_decimalNumberByRestrictingToDigits:_maximumDigits];
  } while (clamped == nil);

  // once we have our artificially clamped value, we can return it
  return clamped;
}

/**
  Puts the calculator into an error state, clearing the operation queue and all cached operator state.  The display is preserved and once the user clears the error, they may choose to make use of it, but all other state is lost.
 */
- (void)setError {
  // mark the rror
  _error = YES;

  // clear the operation queue
  [_tokenQueue clear];

  // clear other state related to the calculation history
  [self clearAccumulator];
  [self clearOperand];
  _operation = EWCCalculatorNoOpcode;
}

///----------------------------
/// @name Other Utility Methods
///----------------------------

/**
  Caller can invoke without worrying about whether the callback is set.  Only tries to invoke the callback if it has been set.
 */
- (void)safeCallback {
  if (_callback) {
    _callback();
  }
}

@end

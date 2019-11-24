//
//  EWCDecimalInputBuilder.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/24/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWCCalculatorKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface EWCDecimalInputBuilder : NSObject

/**
  The number of digits to allow in the value.
 */
@property (nonatomic) NSInteger maximumDigits;

/**
  The number of fractional digits in the current input.
*/
@property (nonatomic, readonly) short fractionalDigitCount;

/**
  The numeric value built up from a series of key presses.

  @note This value can be set, but any input key other than - will immediately reset the input process.  Also after setting, the fractional count will not be accurate, so trailing zeros may not all be displayed.  But as this was set without literal key presses, extra trailing zeros are not expected.
*/
@property (nonatomic) NSDecimalNumber *value;

/**
  Handle an input key.

  The key presses directly handled will be digits, sign, and decimal point.

  @return YES if the key was handled, otherwise NO.
 */
- (BOOL)processKey:(EWCCalculatorKey)key;

/**
  Clear the input state.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END

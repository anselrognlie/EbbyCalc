//
//  EWCCalculatorUserDefaultsData.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/8/19.
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

#import "EWCCalculatorUserDefaultsData.h"

static const char s_taxRateKey[] = "EWCCalculatorTaxRateKey";
static const char s_memoryKey[] = "EWCCalculatorMemoryKey";

@implementation EWCCalculatorUserDefaultsData

///------------------------------
/// @name Property implementation
///------------------------------

- (NSDecimalNumber *)taxRate {
  return [self getDecimalNumberForKey:@(s_taxRateKey) withDefault:[NSDecimalNumber zero]];
}

- (void)setTaxRate:(NSDecimalNumber *)value {
  [self setDecimalNumber:value forKey:@(s_taxRateKey)];
}

- (NSDecimalNumber *)memory {
  return [self getDecimalNumberForKey:@(s_memoryKey) withDefault:[NSDecimalNumber zero]];
}

- (void)setMemory:(NSDecimalNumber *)value {
  [self setDecimalNumber:value forKey:@(s_memoryKey)];
}

///------------------------------
/// @name Internal helper methods
///------------------------------

/**
  Internal helper method that gets a configured `NSNumberFormatter` appropriate for reading or writing the persisted `NSDecimalNumber` values.

  @return The configured formatter.
 */
- (NSNumberFormatter *)getFormatter {
  NSNumberFormatter *formatter = [NSNumberFormatter new];

  // use en_US as a constant formatter style
  formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  formatter.generatesDecimalNumbers = YES;

  return formatter;
}

/**
 Internal helper method that perists a supplied `NSDecimalNumber` value under the supplied name

 @param value The `NSDecimalNumber` value to persist.
 @param key The key under which to persist the value.
*/
- (void)setDecimalNumber:(NSDecimalNumber *)value forKey:(NSString *)key {
  NSNumberFormatter *formatter = [self getFormatter];
  [[NSUserDefaults standardUserDefaults]
    setObject:[formatter stringFromNumber:value]
    forKey:key];
}

/**
 Internal helper method that retrieves an 'NSDecimalNumber' value with the supplied name

 @param key The key used to retrieve the value.
 @param defaultValue A value to return if the key cannot be located, or the stored value cannot otherwise be interpreted.

 @return The value stored under the key, or the default value if an issue is encountered.
*/
- (NSDecimalNumber *)getDecimalNumberForKey:(NSString *)key
  withDefault:(NSDecimalNumber *)defaultValue {

  NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
  if (! str) {
    return defaultValue;
  }

  NSNumberFormatter *formatter = [self getFormatter];
  NSDecimalNumber *num = (NSDecimalNumber *)[formatter numberFromString:str];

  if ([num isEqualToNumber:[NSDecimalNumber notANumber]]) {
    return defaultValue;
  }

  return num;
}

@end

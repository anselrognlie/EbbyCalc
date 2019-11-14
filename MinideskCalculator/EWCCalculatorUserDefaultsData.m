//
//  EWCCalculatorUserDefaultsData.m
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/8/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCCalculatorUserDefaultsData.h"

static const char s_taxRateKey[] = "EWCCalculatorTaxRateKey";
static const char s_memoryKey[] = "EWCCalculatorMemoryKey";

@implementation EWCCalculatorUserDefaultsData

- (NSNumberFormatter *)getFormatter {
  NSNumberFormatter *formatter = [NSNumberFormatter new];

  // use en_US as a constant formatter style
  formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  formatter.generatesDecimalNumbers = YES;

  return formatter;
}

- (void)setDecimalNumber:(NSDecimalNumber *)value forKey:(NSString *)key {
  NSNumberFormatter *formatter = [self getFormatter];
  [[NSUserDefaults standardUserDefaults]
    setObject:[formatter stringFromNumber:value]
    forKey:key];
}

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

@end

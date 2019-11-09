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

- (void)setDecimalNumber:(NSDecimalNumber *)value forKey:(NSString *)key {
  NSDecimal dec = value.decimalValue;
  NSData *data = [NSData dataWithBytes:&dec length:sizeof(dec)];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

- (NSDecimalNumber *)getDecimalNumberForKey:(NSString *)key
  withDefault:(NSDecimalNumber *)defaultValue {

  NSDecimal dec;
  NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
  if (! [obj isKindOfClass:[NSData class]]) {
    return defaultValue;
  }

  NSData *data = (NSData *)obj;
  if (data) {
    [data getBytes:&dec length:sizeof(dec)];
    return [NSDecimalNumber decimalNumberWithDecimal:dec];
  } else {
    return defaultValue;
  }
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

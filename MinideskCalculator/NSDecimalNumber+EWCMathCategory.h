//
//  NSDecimalNumber+EWCMathCategory.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/3/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (EWCMathCategory)

-(NSDecimalNumber *)ewc_decimalNumberBySqrt;
-(NSDecimalNumber *)ewc_decimalNumberBySqrtWithBehavior:(NSDecimalNumberHandler *)handler;
-(NSDecimalNumber *)ewc_decimalNumberByAbsoluteDifferenceFrom:(NSDecimalNumber *)aNumber;

// returns nil if the restriction fails
-(NSDecimalNumber *)ewc_decimalNumberByRestrictingToDigits:(unsigned short)digits;

@end

NS_ASSUME_NONNULL_END

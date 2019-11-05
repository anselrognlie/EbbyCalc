//
//  NSDecimalNumber+EWCMathCategory.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/3/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (EWCMathCategory)
-(NSDecimalNumber *)ewc_decimalNumberBySqrt;
-(NSDecimalNumber *)ewc_decimalNumberBySqrtWithBehavior:(NSDecimalNumberHandler *)handler;
-(NSDecimalNumber *)ewc_decimalNumberByAbsoluteDifferenceFrom:(NSDecimalNumber *)aNumber;
@end

NS_ASSUME_NONNULL_END

//
//  EWCCalculator.h
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

#import <Foundation/Foundation.h>
#import "EWCCalculatorKey.h"

@protocol EWCCalculatorDataProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef void(^EWCCalculatorUpdatedCallback)(void);

@interface EWCCalculator : NSObject

@property (nonatomic, readonly, getter=isMemoryStatusVisible) BOOL memoryStatusVisible;
@property (nonatomic, readonly, getter=isErrorStatusVisible) BOOL errorStatusVisible;
@property (nonatomic, readonly, getter=isTaxStatusVisible) BOOL taxStatusVisible;
@property (nonatomic, readonly, getter=isTaxPlusStatusVisible) BOOL taxPlusStatusVisible;
@property (nonatomic, readonly, getter=isTaxMinusStatusVisible) BOOL taxMinusStatusVisible;
@property (nonatomic, readonly, getter=isTaxPercentStatusVisible) BOOL taxPercentStatusVisible;
@property (nonatomic, readonly, getter=isRateShifted) BOOL rateShifted;
@property (nonatomic, readonly) BOOL shouldMemoryClear;

@property (nonatomic, readonly) NSString *displayContent;
@property (nonatomic, readonly) NSDecimalNumber *displayValue;
@property (nonatomic, readonly) NSString *displayAccessibleContent;
@property (nonatomic) NSInteger maximumDigits;
@property (nonatomic, copy) id<EWCCalculatorDataProtocol> dataProvider;
@property (nonatomic, copy) NSLocale *locale;

+ (instancetype)calculator;

- (void)registerUpdateCallbackWithBlock:(EWCCalculatorUpdatedCallback)callback;
- (void)setInput:(NSDecimalNumber *)value;
- (void)pressKey:(EWCCalculatorKey)key;

@end

NS_ASSUME_NONNULL_END

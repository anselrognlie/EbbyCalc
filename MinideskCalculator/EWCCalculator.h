//
//  EWCCalculator.h
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/29/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

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

@property (nonatomic, readonly) NSString *displayContent;
@property (nonatomic) NSInteger maximumDigits;
@property (nonatomic, copy) id<EWCCalculatorDataProtocol> dataProvider;

+ (instancetype)calculator;

- (void)registerUpdateCallbackWithBlock:(EWCCalculatorUpdatedCallback)callback;

- (void)pressKey:(EWCCalculatorKey)key;

@end

NS_ASSUME_NONNULL_END

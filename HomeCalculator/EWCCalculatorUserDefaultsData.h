//
//  EWCCalculatorUserDefaultsData.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/8/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWCCalculatorDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EWCCalculatorUserDefaultsData : NSObject<EWCCalculatorDataProtocol>

@property (nonatomic) NSDecimalNumber *taxRate;
@property (nonatomic) NSDecimalNumber *memory;

@end

NS_ASSUME_NONNULL_END

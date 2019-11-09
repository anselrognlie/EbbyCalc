//
//  EWCCalculatorDataProtocol.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/8/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EWCCalculatorDataProtocol <NSObject>

@property (nonatomic) NSDecimalNumber *taxRate;
@property (nonatomic) NSDecimalNumber *memory;

@end

NS_ASSUME_NONNULL_END

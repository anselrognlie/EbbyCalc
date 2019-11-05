//
//  EWCNumericField.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/4/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EWCNumericField : NSObject

@property (nonatomic, getter=isEmpty) BOOL empty;
@property (nonatomic) NSDecimalNumber *value;

- (instancetype)init;
- (void)clear;

@end

NS_ASSUME_NONNULL_END

//
//  EWCCalculatorToken.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWCCalculatorKey.h"
#import "EWCCalculatorOpcode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EWCCalculatorTokenType) {
  EWCCalculatorEmptyTokenType = 1,
  EWCCalculatorBinOpTokenType,
  EWCCalculatorDataTokenType,
  EWCCalculatorEqualTokenType,
};

@interface EWCCalculatorToken : NSObject <NSCopying>

@property (nonatomic, readonly) EWCCalculatorTokenType tokenType;
@property (nonatomic, readonly) NSDecimalNumber *data;
@property (nonatomic, readonly) EWCCalculatorOpcode opcode;

+ (instancetype)tokenWithData:(NSDecimalNumber *)data;
+ (instancetype)tokenWithBinOp:(EWCCalculatorOpcode)opcode;
+ (instancetype)tokenAsEqual;

+ (instancetype)empty;

- (instancetype)init;
- (instancetype)initWithData:(NSDecimalNumber *)data;
- (instancetype)initWithBinOp:(EWCCalculatorOpcode)opcode;
- (instancetype)initAsEqual;

- (nonnull instancetype)copyWithZone:(nullable NSZone *)zone;

@end

NS_ASSUME_NONNULL_END

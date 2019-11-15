//
//  EWCCalculatorToken.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/5/19.
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
#import "EWCCalculatorOpcode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EWCCalculatorTokenType) {
  EWCCalculatorEmptyTokenType = 0,
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
+ (instancetype)tokenWithEqual:(EWCCalculatorOpcode)opcode;

+ (instancetype)empty;

- (instancetype)init;
- (instancetype)initWithData:(NSDecimalNumber *)data;
- (instancetype)initWithBinOp:(EWCCalculatorOpcode)opcode;
- (instancetype)initWithEqual:(EWCCalculatorOpcode)opcode;

- (nonnull instancetype)copyWithZone:(nullable NSZone *)zone;

@end

NS_ASSUME_NONNULL_END

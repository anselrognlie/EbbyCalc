//
//  EWCCalculatorToken.h
//  EbbyCalc
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

/**
  `EWCCalculatorTokenType` categorizes the type of data stored in a `EWCCalculatorToken`.
 */
typedef NS_ENUM(NSInteger, EWCCalculatorTokenType) {
  EWCCalculatorEmptyTokenType = 0,
  EWCCalculatorBinOpTokenType,
  EWCCalculatorDataTokenType,
  EWCCalculatorEqualTokenType,
};

/**
  `EWCCalculatorToken` represents an input in the calculator's operation key.
 */
@interface EWCCalculatorToken : NSObject

///-----------------
/// @name Properties
///-----------------

/**
  The type of token content
 */
@property (nonatomic, readonly) EWCCalculatorTokenType tokenType;

/**
  The numeric value for a token holding data.
 */
@property (nonatomic, readonly) NSDecimalNumber *data;

/**
  The opcode for a token holding a binary or equal operation.
 */
@property (nonatomic, readonly) EWCCalculatorOpcode opcode;

///------------------------------------------
/// @name Creation and Initialization Methods
///------------------------------------------

/**
  Creates a token holding numeric data.

  @param data The numeric data to store in the token.

  @return The new token instance.
 */
+ (instancetype)tokenWithData:(NSDecimalNumber *)data;

/**
 Creates a token holding a binary operation.

 @param opcode The opcode to store in the token.

 @return The new token instance.
*/
+ (instancetype)tokenWithBinOp:(EWCCalculatorOpcode)opcode;

/**
 Creates a token holding an equal operation.

 @param opcode The opcode to store in the token.

 @return The new token instance.
*/
+ (instancetype)tokenWithEqual:(EWCCalculatorOpcode)opcode;

/**
 Creates an empty token.

 @return The new token instance.
*/
+ (instancetype)empty;

/**
 Initializes an empty token.

 @return The new token instance.
*/
- (instancetype)init;

/**
 Initializes a token holding numeric data.

 @param data The numeric data to store in the token.

 @return The initialized token instance.
*/
- (instancetype)initWithData:(NSDecimalNumber *)data;

/**
 Initializes a token holding a binary operation opcode.

 @param opcode The opcode to store in the token.

 @return The initialized token instance.
*/
- (instancetype)initWithBinOp:(EWCCalculatorOpcode)opcode;

/**
 Initializes a token holding numeric data.

 @param opcode The opcode to store in the token.

 @return The initialized token instance.
*/
- (instancetype)initWithEqual:(EWCCalculatorOpcode)opcode;

@end

NS_ASSUME_NONNULL_END

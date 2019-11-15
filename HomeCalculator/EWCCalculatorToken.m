//
//  EWCCalculatorToken.m
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

#import "EWCCalculatorToken.h"

@interface EWCCalculatorToken ()

@property (nonatomic, readwrite) EWCCalculatorTokenType tokenType;
@property (nonatomic, readwrite) NSDecimalNumber *data;
@property (nonatomic, readwrite) EWCCalculatorOpcode opcode;

@end

static EWCCalculatorToken *s_empty = nil;

@implementation EWCCalculatorToken

+ (instancetype)tokenWithData:(NSDecimalNumber *)data {
  return [[EWCCalculatorToken alloc] initWithData:data];
}

+ (instancetype)tokenWithBinOp:(EWCCalculatorOpcode)opcode {
  return [[EWCCalculatorToken alloc] initWithBinOp:opcode];
}

+ (instancetype)tokenWithEqual:(EWCCalculatorOpcode)opcode {
  return [[EWCCalculatorToken alloc] initWithEqual:opcode];
}

+ (void)initialize {
  s_empty = [EWCCalculatorToken new];
}

+ (instancetype)empty {
  return s_empty;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.tokenType = EWCCalculatorEmptyTokenType;
  }
  return self;
}

- (instancetype)initWithData:(NSDecimalNumber *)data {
  self = [super init];
  if (self) {
    self.tokenType = EWCCalculatorDataTokenType;
    self.data = data;
  }
  return self;
}

- (instancetype)initWithBinOp:(EWCCalculatorOpcode)opcode {
  self = [super init];
  if (self) {
    self.tokenType = EWCCalculatorBinOpTokenType;
    self.opcode = opcode;
  }
  return self;
}

- (instancetype)initWithEqual:(EWCCalculatorOpcode)opcode {
  self = [super init];
  if (self) {
    self.tokenType = EWCCalculatorEqualTokenType;
    self.opcode = opcode;
  }
  return self;
}

- (nonnull instancetype)copyWithZone:(nullable NSZone *)zone {
  EWCCalculatorToken *newToken = [[EWCCalculatorToken allocWithZone:zone] init];
  if (newToken) {
    newToken.tokenType = _tokenType;
    newToken.opcode = _opcode;
    newToken.data = [_data copyWithZone:zone];
  }

  return newToken;
}

@end

//
//  EWCKeyCommandCalculatorRecord.m
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/28/19.
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

#import "EWCKeyCommandCalculatorRecord.h"

@implementation EWCKeyCommandCalculatorRecord

///-------------------------------------
/// @name Constructors and Initializers.
///-------------------------------------

+ (instancetype)recordWithCommand:(UIKeyCommand *)command calculatorKey:(EWCCalculatorKey)key {
  EWCKeyCommandCalculatorRecord *record = [[EWCKeyCommandCalculatorRecord alloc]
    initWithCommand:command calculatorKey:key];

  return record;
}

- (instancetype)initWithCommand:(UIKeyCommand *)command calculatorKey:(EWCCalculatorKey)key {
  self = [super init];
  if (self) {
    _command = [command copy];
    _calculatorKey = key;
  }

  return self;
}

@end

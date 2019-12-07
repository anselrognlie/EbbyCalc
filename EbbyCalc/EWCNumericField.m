//
//  EWCNumericField.m
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/4/19.
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

#import "EWCNumericField.h"

@implementation EWCNumericField

- (instancetype)init {
  self = [super init];
  if (self) {
    _value = [NSDecimalNumber zero];
    _empty = YES;
  }
  return self;
}

- (void)setValue:(NSDecimalNumber *)value {
  _value = value;
  _empty = NO;
}

- (void)clear {
  _value = [NSDecimalNumber zero];
  _empty = YES;
}

@end

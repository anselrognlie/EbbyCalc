//
//  EWCNumericField.h
//  HomeCalculator
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
  `EWCNumericField` represents a storage area in the calculator for a numeric value.

  In practice, this idea was under-developed, but it's not bad enough to rip out.
 */
@interface EWCNumericField : NSObject

/**
  Whether the field is empty.  If the field reports itself as empty, the value must be ignored.
 */
@property (nonatomic, getter=isEmpty) BOOL empty;

/**
  The data value stored in the field.
 */
@property (nonatomic) NSDecimalNumber *value;

/**
  Initializes an empty field.

  @return The initialized instance.
 */
- (instancetype)init;

/**
  Clears the field, rendering it empty.
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END

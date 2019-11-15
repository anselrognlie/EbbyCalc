//
//  EWCCalculatorUserDefaultsData.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/8/19.
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
#import "EWCCalculatorDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `EWCCalculatorUserDefaultsData` implements the `EWCCalculatorDataProtocol` protocol used by `EWCCalculator` to persist the calculator's memory storage.

  It serializes the NSDecimalNumber values to the standard NSUSerDefaults as strings rendered under the en_US locale.
*/
@interface EWCCalculatorUserDefaultsData : NSObject<EWCCalculatorDataProtocol>

/**
  Stores or reads the tax rate used for tax+ and tax- operations.
 */
@property (nonatomic) NSDecimalNumber *taxRate;

/**
  Stores or reads the single general purpose memory location.
 */
@property (nonatomic) NSDecimalNumber *memory;

@end

NS_ASSUME_NONNULL_END

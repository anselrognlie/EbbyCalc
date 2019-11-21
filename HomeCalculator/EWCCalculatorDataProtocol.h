//
//  EWCCalculatorDataProtocol.h
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

NS_ASSUME_NONNULL_BEGIN

/**
  `EWCCalculatorDataProtocol` provides methods the `EWCCalculator` can use to store persistent state.
 */
@protocol EWCCalculatorDataProtocol <NSObject>

/**
  The tax rate for tax add and deduct calculations.  This should persiste between app launches.
*/
@property (nonatomic) NSDecimalNumber *taxRate;

/**
  The single general-purpose memory value.  This should persiste between app launches.
*/
@property (nonatomic) NSDecimalNumber *memory;

@end

NS_ASSUME_NONNULL_END

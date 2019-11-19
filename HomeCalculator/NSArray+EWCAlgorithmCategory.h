//
//  NSArray+EWCAlgorithmCategory.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/7/19.
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
  `NSArray+EWCAlgorithmCategory` contains category methods for working with arrays of doubles (as `NSNumber` instances).
 */
@interface NSArray (EWCAlgorithmCategory)

/**
  Given an array of doubles, this will calculate the sum.

  @return The sum of the doubles in the array.
 */
- (CGFloat)ewc_totalDouble;

/**
 Given an array of doubles, this will find the minimum value.

 @return The minimum value or 0 if the array is empty.
*/
- (CGFloat)ewc_minDouble;

@end

NS_ASSUME_NONNULL_END

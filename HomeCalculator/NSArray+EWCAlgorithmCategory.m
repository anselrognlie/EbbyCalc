//
//  NSArray+EWCAlgorithmCategory.m
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

#import "NSArray+EWCAlgorithmCategory.h"

@implementation NSArray (EWCAlgorithmCategory)

- (CGFloat)ewc_totalDouble {
  CGFloat total = 0;
  for (NSNumber *num in self) {
    total += num.doubleValue;
  }

  return total;
}

- (CGFloat)ewc_minDouble {
  if (self.count == 0) {
    return 0;
  }

  CGFloat min = ((NSNumber *)self[0]).doubleValue;
  for (NSNumber *num in self) {
    CGFloat cmp = num.doubleValue;
    if (cmp < min) {
      min = cmp;
    }
  }

  return min;
}

@end

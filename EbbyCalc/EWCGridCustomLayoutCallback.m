//
//  EWCGridCustomLayoutCallback.m
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/20/19.
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
  Block type for a callback used for a control to perform cusomt layout within the grid.

  @param view The control to be laid out.
  @param frame The area within the grid in which the control would normally be laid out.  This might not be the size of a single cell if the control spans multiple cells.  Gutter adjustments have already been made.
  @param cellWidth The width of a single grid cell.  Gutter adjustments have already been made.
  @param cellHeight The height of a single grid cell.  Gutter adjustments have already been made.
 */
typedef void(^EWCGridCustomLayoutCallback)(UIView *view, CGRect frame, CGFloat cellWidth, CGFloat cellHeight);

NS_ASSUME_NONNULL_END

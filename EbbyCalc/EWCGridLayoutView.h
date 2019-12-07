//
//  EWCGridLayoutView.h
//  EbbyCalc
//
//  Created by Ansel Rognlie on 10/25/19.
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
#import "EWCGridCustomLayoutCallback.m"

NS_ASSUME_NONNULL_BEGIN

/**
  `EWCGridLayoutView` lays out its child controls on a regular grid.

  Child controls may span multiple cells, and must be able to be positioned according to their frame rather than AutoLayout constraints.  That is, the should not use an instrinsic size, but receive their size from their container.
 */
@interface EWCGridLayoutView : UIView

///--------------------------------------
/// @name Layout Configuration Properties
///--------------------------------------

/**
  The number of rows in the grid.
 */
@property (nonatomic) NSInteger rows;

/**
  The number of columns in the grid.
 */
@property (nonatomic) NSInteger columns;

/**
  The gutter size between rows as a percentage of height.
 */
@property (nonatomic) float rowGutter;

/**
 The gutter size between columns as a percentage of width.
*/
@property (nonatomic) float columnGutter;

/**
 Whether to display debug draw output.
*/
@property (nonatomic) BOOL showDebugDraw;

///----------------------------------
/// @name Methods for Adding Children
///----------------------------------

/**
 Adds the supplied view to the grid for layout management.

 @param subView The child view instance to add to the grid.
 @param row The row to be occupied by the managed view.
 @param column The column to be occupied by the managed view.
*/
- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column;

/**
 Adds the supplied view to the grid for layout management.

 @param subView The child view instance to add to the grid.
 @param startRow The first row to be occupied by the managed view.
 @param startColumn The first column to be occupied by the managed view.
 @param endRow The last row to be occupied by the managed view.
 @param endColumn The last column to be occupied by the managed view.
*/
- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn;

/**
 Adds the supplied view to the grid for layout management.

 @param subView The child view instance to add to the grid.
 @param row The row to be occupied by the managed view.
 @param column The column to be occupied by the managed view.
 @param callback An optional callback that can be used to customize the view layout.  Pass nil to use the default layout.
*/
- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column
  withLayout:(nullable EWCGridCustomLayoutCallback)callback;

/**
  Adds the supplied view to the grid for layout management.

  @param subView The child view instance to add to the grid.
  @param startRow The first row to be occupied by the managed view.
  @param startColumn The first column to be occupied by the managed view.
  @param endRow The last row to be occupied by the managed view.
  @param endColumn The last column to be occupied by the managed view.
  @param callback An optional callback that can be used to customize the view layout.  Pass nil to use the default layout.
 */
- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn
  withLayout:(nullable EWCGridCustomLayoutCallback)callback;

@end

NS_ASSUME_NONNULL_END

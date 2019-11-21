//
//  EWCGridLayoutProps.h
//  HomeCalculator
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
#import "EWCGridCustomLayoutCallback.m"

NS_ASSUME_NONNULL_BEGIN

/**
  `EWCRowColumnBounds` gathers together a few properties related to how a control should be managed by the grid.
 */
typedef struct {
  NSInteger startRow;  // the first row occupied by a control
  NSInteger startColumn;  // the first column occupied by a control
  NSInteger endRow;  // the last row occupied by a control
  NSInteger endColumn;  // the last column occupied by a control
  EWCGridCustomLayoutCallback layoutCallback;  // an optional custom callback to modify the layout of the control
} EWCRowColumnBounds;

/**
  `EWCGridLayoutProps` holds a control and its settings for how it should be deisplayed in the grid.  It can be stored in containers by virtue of extending NSObject.
 */
@interface EWCGridLayoutProps : NSObject

/**
  The view being positioned.
 */
@property (nonatomic, weak) UIView *view;

/**
  Configuration information for the view.
 */
@property (nonatomic) EWCRowColumnBounds bounds;

/**
  Creates a new properties instance with the supplied configuration.

  @param view The view to be positioned.
  @param startRow The first row to be occupied by the managed view.
  @param startColumn The first column to be occupied by the managed view.
  @param endRow The last row to be occupied by the managed view.
  @param endColumn The last column to be occupied by the managed view.
  @param callback An optional callback that can be used to customize the view layout.  Pass nil to use the default layout.
 */
+ (instancetype)propsForView:(UIView *)view
  withStartingRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingRow:(NSInteger)endRow column:(NSInteger)endColumn
  withLayout:(nullable EWCGridCustomLayoutCallback)callback;

@end

NS_ASSUME_NONNULL_END

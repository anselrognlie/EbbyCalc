//
//  EWCGridLayoutView.h
//  HomeCalculator
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EWCGridLayoutCellStyle) {
  EWCGridLayoutCellAspectRatioStyle = 1,
  EWCGridLayoutCellFillStyle,
};

typedef void(^EWCGridCustomLayoutCallback)(UIView *view, CGRect frame, CGFloat minWidth, CGFloat minHeight);

@interface EWCGridLayoutView : UIView

@property (nonatomic, strong) NSArray<NSNumber *> *rows;
@property (nonatomic, strong) NSArray<NSNumber *> *columns;
@property (nonatomic) float minRowGutter;  // provided as percent of total dimension
@property (nonatomic) float minColumnGutter;
@property (nonatomic) float maxRowGutter;  // provided as percent of total dimension
@property (nonatomic) float maxColumnGutter;
@property (nonatomic) EWCGridLayoutCellStyle cellStyle;
@property (nonatomic) float cellAspectRatio;  // w:h
@property (nonatomic, readonly) float calculatedRowGutter;
@property (nonatomic, readonly) float calculatedColumnGutter;

- (float)columnWidth:(NSInteger)column;
- (float)rowHeight:(NSInteger)row;

- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column;

- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn;

- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column
  withLayout:(nullable EWCGridCustomLayoutCallback)callback;

- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn
  withLayout:(nullable EWCGridCustomLayoutCallback)callback;

@end

NS_ASSUME_NONNULL_END

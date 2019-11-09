//
//  EWCGridLayoutView.h
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/25/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

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

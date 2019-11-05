//
//  EWCGridLayoutView.m
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/25/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCGridLayoutView.h"

typedef struct {
  NSInteger startRow;
  NSInteger startColumn;
  NSInteger endRow;
  NSInteger endColumn;
} EWCRowColumnBounds;

@interface EWCGridLayoutProps : NSObject
@property (nonatomic, weak) UIView *view;
@property (nonatomic) EWCRowColumnBounds bounds;

+ (instancetype)propsForView:(UIView *)view
  withStartingRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingRow:(NSInteger)endRow column:(NSInteger)endColumn;

@end

@implementation EWCGridLayoutProps
+ (instancetype)propsForView:(UIView *)view
  withStartingRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingRow:(NSInteger)endRow column:(NSInteger)endColumn {

  EWCGridLayoutProps *props = [EWCGridLayoutProps new];
  props.view = view;
  props.bounds = (EWCRowColumnBounds){
    startRow, startColumn, endRow, endColumn
  };

  return props;
}
@end

@interface EWCGridLayoutView() {
  NSMapTable<UIView *, EWCGridLayoutProps *> *_layoutProps;
  CGFloat _totalColumnWidths;
  CGFloat _totalRowWidths;
  __weak UIButton *_currentButton;
}

@end

static void setStrokeColor(CGContextRef context, UIColor *color);
//static void setFillColor(CGContextRef context, UIColor *color);

@implementation EWCGridLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self internalInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self internalInit];
  }
  return self;
}

- (void)internalInit {
  self.translatesAutoresizingMaskIntoConstraints = NO;
  self.multipleTouchEnabled = NO;
  _rows = @[];
  _columns = @[];
  _minRowGutter = 0;
  _minColumnGutter = 0;
  _maxRowGutter = 0;
  _maxColumnGutter = 0;
  _cellAspectRatio = 1.0;
  _cellStyle = EWCGridLayoutCellFillStyle;
  _layoutProps = [NSMapTable<UIView *, EWCGridLayoutProps *> weakToStrongObjectsMapTable];
  _currentButton = nil;
}

- (float)calculatedRowGutter {
  return self.bounds.size.height * _minRowGutter;
}

- (float)calculatedColumnGutter {
  return self.bounds.size.width * _minColumnGutter;
}

- (float)columnWidth:(NSInteger)column {
  return _columns[column].floatValue / [self totalColumnWeight] * self.bounds.size.width;
}

- (float)rowHeight:(NSInteger)row {
  return _rows[row].floatValue / [self totalRowWeight] * self.bounds.size.height;
}

- (void)dealloc {
}

- (void)layoutSubviews {

  [super layoutSubviews];

  CGFloat rowTotal = self.totalRowWeight;
  CGFloat columnTotal = self.totalColumnWeight;
  CGFloat gridWidth = self.frame.size.width;
  CGFloat gridHeight = self.frame.size.height;

  // layout any child objects based on the props
  for (EWCGridLayoutProps *props in [_layoutProps objectEnumerator]) {
    UIView *view = props.view;
    EWCRowColumnBounds bounds = props.bounds;

    // sum the rows and columns spanned by this view
    CGFloat rowSpan = 0, rowTop = 0, colSpan = 0, colLeft = 0;
    for (NSInteger r = 0; r <= bounds.endRow; ++r) {
      if (r < bounds.startRow) {
        rowTop += _rows[r].floatValue;
      } else {
        rowSpan += _rows[r].floatValue;
      }
    }
    for (NSInteger c = 0; c <= bounds.endColumn; ++c) {
      if (c < bounds.startColumn) {
        colLeft += _columns[c].floatValue;
      } else {
        colSpan += _columns[c].floatValue;
      }
    }

    CGFloat top, right, bottom, left, width, height;
    top = gridHeight * (rowTop / rowTotal);
    height = gridHeight * (rowSpan / rowTotal);
    bottom = top + height;
    left = gridWidth * (colLeft / columnTotal);
    width = gridWidth * (colSpan / columnTotal);
    right = left + width;

    CGFloat gutterWidth = self.minRowGutter * gridWidth / 2.0;
    CGFloat gutterHeight = self.minColumnGutter * gridHeight / 2.0;

//    CGRect oldFrame = view.frame;
    CGRect childFrame = CGRectMake(
      left + gutterWidth,
      top + gutterHeight,
      width - (2 * gutterWidth),
      height - (2 * gutterHeight));
    view.frame = childFrame;

    [view layoutIfNeeded];
  }

  [super layoutSubviews];
}

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (CGFloat)totalRowWeight {
  return [self totalWeight:_rows];
}

- (CGFloat)totalWeight:(NSArray<NSNumber *> *)array {
  CGFloat total = 0;
  for (NSNumber *num in array) {
    total += num.floatValue;
  }

  if (total == 0.0) {
    total = 1.0;
  }

  return total;
}

- (CGFloat)totalColumnWeight {
  return [self totalWeight:_columns];
}

//- (void)drawRect:(CGRect)rect {
//  [self debugDraw];
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  [self handleTouch:touch];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  [self handleTouch:touch];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  [self handleTouchEnded:touch];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self clearTouches];
}

- (void)handleTouch:(UITouch *)touch {
  CGPoint pos = [touch locationInView:self];

  for (UIView *view in _layoutProps.keyEnumerator) {
    if ([view isKindOfClass:[UIButton class]]) {
      UIButton *button = (UIButton *)view;

      // is the touch in the ui element?
      if (CGRectContainsPoint(button.frame, pos)) {
        // if not the current button, unhighlight the old and highlight the new
        if (button != _currentButton) {
          [self clearCurrentButton];
          _currentButton = button;
          [button setHighlighted:YES];
        }

        // done processing buttons
        break;
      }
    }
  }

  // no button found
  [ self clearCurrentButton];
}

- (void)handleTouchEnded:(UITouch *)touch {

  CGPoint pos = [touch locationInView:self];

  for (UIView *view in _layoutProps.keyEnumerator) {
    if ([view isKindOfClass:[UIButton class]]) {
      UIButton *button = (UIButton *)view;

      // is the touch in the ui element?
      if (CGRectContainsPoint(button.frame, pos)) {
        // clear the current (which should be this, but doesn't matter if not)
        [self clearCurrentButton];

        // handle the current button
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];

        // done processing buttons
        break;
      }
    }
  }
}

- (void)clearTouches {
  [self clearCurrentButton];
}

- (void)clearCurrentButton {
  if (_currentButton) {
    [_currentButton setHighlighted:NO];
    _currentButton = nil;
  }
}

- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column {

  [self addSubView:subView startingInRow:row column:column
    endingInRow:row column:column];
}

- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn {

  [self addSubview:subView];
  [_layoutProps setObject:[EWCGridLayoutProps propsForView:subView
    withStartingRow:startRow column:startColumn
    endingRow:endRow column:endColumn] forKey:subView];
}

- (void)debugDraw {
  CGContextRef ctx = UIGraphicsGetCurrentContext();

  setStrokeColor(ctx, UIColor.systemOrangeColor);

  CGContextBeginPath(ctx);

  CGFloat rowTotal = self.totalRowWeight;
  CGFloat columnTotal = self.totalColumnWeight;
  CGFloat width = self.frame.size.width;
  CGFloat height = self.frame.size.height;

  // draw row dividers
  CGFloat rowOffset = 0.0;
  for (int i = 0; i < _rows.count - 1; ++i) {
    CGFloat row = _rows[i].floatValue;
    rowOffset += row;
    CGFloat y = (rowOffset / rowTotal) * height;
    CGContextMoveToPoint(ctx, 0, y);
    CGContextAddLineToPoint(ctx, width, y);
  }

  // draw column dividers
  CGFloat columnOffset = 0.0;
  for (int i = 0; i < _columns.count - 1; ++i) {
    CGFloat column = _columns[i].floatValue;
    columnOffset += column;
    CGFloat x = (columnOffset / columnTotal) * width;
    CGContextMoveToPoint(ctx, x, 0);
    CGContextAddLineToPoint(ctx, x, height);
  }

  CGContextClosePath(ctx);
  CGContextDrawPath(ctx, kCGPathStroke);

  // min gutters
  setStrokeColor(ctx, UIColor.systemGreenColor);

  CGContextBeginPath(ctx);

  if (_minRowGutter > 0) {
    CGFloat gutterSize = _minRowGutter * height / 2.0;
    CGFloat rowOffset = 0.0;
    for (int i = 0; i < _rows.count - 1; ++i) {
      CGFloat row = _rows[i].floatValue;
      rowOffset += row;
      CGFloat y = (rowOffset / rowTotal) * height;
      CGContextMoveToPoint(ctx, 0, y - gutterSize);
      CGContextAddLineToPoint(ctx, width, y - gutterSize);
      CGContextMoveToPoint(ctx, 0, y + gutterSize);
      CGContextAddLineToPoint(ctx, width, y + gutterSize);
    }

    CGContextMoveToPoint(ctx, 0, gutterSize);
    CGContextAddLineToPoint(ctx, width, gutterSize);

    CGContextMoveToPoint(ctx, 0, height - gutterSize);
    CGContextAddLineToPoint(ctx, width, height - gutterSize);
  }

  if (_minColumnGutter > 0) {
    CGFloat gutterSize = _minColumnGutter * width / 2.0;
    CGFloat columnOffset = 0.0;
    for (int i = 0; i < _columns.count - 1; ++i) {
      CGFloat column = _columns[i].floatValue;
      columnOffset += column;
      CGFloat x = (columnOffset / columnTotal) * width;
      CGContextMoveToPoint(ctx, x - gutterSize, 0);
      CGContextAddLineToPoint(ctx, x - gutterSize, height);
      CGContextMoveToPoint(ctx, x + gutterSize, 0);
      CGContextAddLineToPoint(ctx, x + gutterSize, height);
    }

    CGContextMoveToPoint(ctx, gutterSize, 0);
    CGContextAddLineToPoint(ctx, gutterSize, height);

    CGContextMoveToPoint(ctx, width - gutterSize, 0);
    CGContextAddLineToPoint(ctx, width - gutterSize, height);
  }

  CGContextClosePath(ctx);
  CGContextDrawPath(ctx, kCGPathStroke);
}

@end

static void setStrokeColor(CGContextRef context, UIColor *color)
{
  CGFloat r, g, b, a;
  [color getRed:&r green:&g blue:&b alpha:&a];
  CGContextSetRGBStrokeColor(context, r, g, b, a);
}

//static void setFillColor(CGContextRef context, UIColor *color)
//{
//  CGFloat r, g, b, a;
//  [color getRed:&r green:&g blue:&b alpha:&a];
//  CGContextSetRGBFillColor(context, r, g, b, a);
//}

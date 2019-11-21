//
//  EWCGridLayoutView.m
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

#import "EWCGridLayoutView.h"
#import "EWCGridLayoutProps.h"

/**
  Static helper to assign the current stroke color

  @param context The current graphics context.
  @param color The color to use for the stroke color.
 */
static void setStrokeColor(CGContextRef context, UIColor *color)
{
  CGFloat r, g, b, a;
  [color getRed:&r green:&g blue:&b alpha:&a];
  CGContextSetRGBStrokeColor(context, r, g, b, a);
}

@interface EWCGridLayoutView() {
  NSMapTable<UIView *, EWCGridLayoutProps *> *_layoutProps;  // track the configurations of the child views
  __weak UIButton *_currentChild;  // track the last child that was the target of a touch event
}

@end

@implementation EWCGridLayoutView

///--------------------------------------------
/// @name Public Methods (documented in header)
///--------------------------------------------

- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column {

  [self addSubView:subView inRow:row column:column withLayout:nil];
}

- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn {

  [self addSubView:subView startingInRow:startRow column:startColumn
    endingInRow:endRow column:endColumn withLayout:nil];
}

- (void)addSubView:(UIView *)subView
  inRow:(NSInteger)row column:(NSInteger)column
  withLayout:(nullable EWCGridCustomLayoutCallback)callback {

  [self addSubView:subView startingInRow:row column:column
    endingInRow:row column:column withLayout:callback];
}

- (void)addSubView:(UIView *)subView
  startingInRow:(NSInteger)startRow column:(NSInteger)startColumn
  endingInRow:(NSInteger)endRow column:(NSInteger)endColumn
  withLayout:(nullable EWCGridCustomLayoutCallback)callback {

  if (subView.superview != self) {
    [self addSubview:subView];
  }

  [_layoutProps setObject:[EWCGridLayoutProps propsForView:subView
    withStartingRow:startRow column:startColumn
    endingRow:endRow column:endColumn withLayout:callback] forKey:subView];
}

///-------------------
/// @name Initializers
///-------------------

/**
 Initializer typically used when declared in code.

 @param frame The display dimensions of the view.

 @return The initialized instance.
*/
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self internalInit];
  }
  return self;
}

/**
  Initializer used when loaded from a xib file.

  @param coder An unarchiver object.

  @return The initialized instance.
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self internalInit];
  }
  return self;
}

/**
  Shared initialization logic.  Just sets state to reasonable defaults and allocates containers.
 */
- (void)internalInit {
  self.translatesAutoresizingMaskIntoConstraints = NO;
  self.multipleTouchEnabled = NO;
  _rows = 0;
  _columns = 0;
  _rowGutter = 0;
  _columnGutter = 0;
  _layoutProps = [NSMapTable<UIView *, EWCGridLayoutProps *> weakToStrongObjectsMapTable];
  _currentChild = nil;
  _showDebugDraw = NO;
}

///--------------------------------
/// @name Overridden UIView Methods
///--------------------------------

/**
  Lays out subviews.

  Called once the view's own dimensions have been established, so it is now safe to use them in laying out any children.

  Our implementation examines the configuration for each registered child, calculates a suitable frame, and sets it.  If the child has a layout callback, we pass that data along with the calculated minimum cell dimensions and leave it to the callback to handle the layout.
 */
- (void)layoutSubviews {

  CGFloat rowTotal = _rows;
  CGFloat columnTotal = _columns;
  CGFloat gridWidth = self.frame.size.width;
  CGFloat gridHeight = self.frame.size.height;
  CGFloat rowGutter = self.rowGutter;
  CGFloat columnGutter = self.columnGutter;

  // determine the minimum width and height in case a control requests
  // custom layout
  CGFloat minWidth = 0, minHeight = 0;
  {
    CGRect minFrame = [self makeChildRectForGridHeight:gridHeight
      gridWidth:gridWidth
      rowTop:0
      rowSpan:1.0
      rowGutter:rowGutter
      rowTotal:rowTotal
      columnLeft:0
      columnSpan:1.0
      columnGutter:columnGutter
      columnTotal:columnTotal];

    minHeight = minFrame.size.height;
    minWidth = minFrame.size.width;
  }

  // layout any child objects based on the props
  for (EWCGridLayoutProps *props in [_layoutProps objectEnumerator]) {
    UIView *view = props.view;
    EWCRowColumnBounds bounds = props.bounds;

    // sum the rows and columns spanned by this view
    CGFloat rowSpan = 0, rowTop = 0, columnSpan = 0, columnLeft = 0;
    for (NSInteger r = 0; r <= bounds.endRow; ++r) {
      if (r < bounds.startRow) {
        rowTop += 1.0;
      } else {
        rowSpan += 1.0;
      }
    }
    for (NSInteger c = 0; c <= bounds.endColumn; ++c) {
      if (c < bounds.startColumn) {
        columnLeft += 1.0;
      } else {
        columnSpan += 1.0;
      }
    }

    // Calculate a frame that encompasses the grid area.
    CGRect childFrame = [self makeChildRectForGridHeight:gridHeight
      gridWidth:gridWidth
      rowTop:rowTop
      rowSpan:rowSpan
      rowGutter:rowGutter
      rowTotal:rowTotal
      columnLeft:columnLeft
      columnSpan:columnSpan
      columnGutter:columnGutter
      columnTotal:columnTotal];

    // if the record for the current child has a custom callback, allow that
    // to perform layout.  Otherwise, just use the calculated grid area to set
    // the child frame.

    if (bounds.layoutCallback != nil) {
      bounds.layoutCallback(view, childFrame, minWidth, minHeight);
    } else {
      view.frame = childFrame;
    }

    // give the view a chance to lay itself out if the frame changes require it
    [view layoutIfNeeded];
  }
}

/**
  Determines whether a touch even occurred within this instance.

  @param point The point to test.
  @param event The event related to the touch event.

  @return We just always return YES.
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  return YES;
}

///-------------------------------------
/// @name Overridden UIResponder Methods
///-------------------------------------

/**
  Called when a touch event begins.

  @param touches The collection of touches.  Since we don't allow multitouch, there should only be one touch.
  @param event Event details about the touch.  Ignored.
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // get a touch from the collection and handle it
  UITouch *touch = [touches anyObject];
  [self handleTouch:touch];
}

/**
 Called when a touch event moves within the instance.

 @param touches The collection of touches.  Since we don't allow multitouch, there should only be one touch.
 @param event Event details about the touch.  Ignored.
*/
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // get a touch from the collection and handle it
  UITouch *touch = [touches anyObject];
  [self handleTouch:touch];
}

/**
 Called when the user releases their touch.

 @param touches The collection of touches.  Since we don't allow multitouch, there should only be one touch.
 @param event Event details about the touch.  Ignored.
*/
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // get a touch from the collection and handle it
  UITouch *touch = [touches anyObject];
  [self handleTouchEnded:touch];
}

/**
 Called when something happens that interrupts a touch event.  We just halt our touch processing.

 @param touches The collection of touches.  Ignored.
 @param event Event details about the touch.  Ignored.
*/
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // just halt touch processing
  [self clearTouches];
}

///------------------------------
/// @name CALayerDelegate Methods
///------------------------------

/**
  Delegate method that is called when a managed layer needs to be drawn.

  By default, iOS makes the view a layer belongs to the default delegate.

  @param layer The layer that needs to be drawn.  Ignored.
  @param ctx The current context to use for drawing.
 */
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
  if (_showDebugDraw) {
    [self debugDrawInContext:ctx];
  }
}

///----------------------------
/// @name Layout Helper Methods
///----------------------------

/**
  Creates a frame for a grid region according to the supplied configuration.

  @param gridHeight The total height of the grid.
  @param gridWidth The total width of the grid.
  @param rowTop The row where the grid area starts.
  @param rowSpan The number of rows the grid area spans.
  @param rowGutter The row gutter setting (a percent of the grid height).
  @param rowTotal The total number of rows in the grid.
  @param columnLeft The columns where the grid area starts.
  @param columnSpan The number of columns the grid area spans.
  @param columnGutter The column gutter setting (a percent of the grid width).
  @param columnTotal The total number of columns in the grid.

  @return The frame area of the specified grid region.
 */
- (CGRect)makeChildRectForGridHeight:(CGFloat)gridHeight
  gridWidth:(CGFloat)gridWidth
  rowTop:(CGFloat)rowTop
  rowSpan:(CGFloat)rowSpan
  rowGutter:(CGFloat)rowGutter
  rowTotal:(CGFloat)rowTotal
  columnLeft:(CGFloat)columnLeft
  columnSpan:(CGFloat)columnSpan
  columnGutter:(CGFloat)columnGutter
  columnTotal:(CGFloat)columnTotal {

  CGFloat top, right, bottom, left, width, height;
  top = gridHeight * (rowTop / rowTotal);
  height = gridHeight * (rowSpan / rowTotal);
  bottom = top + height;
  left = gridWidth * (columnLeft / columnTotal);
  width = gridWidth * (columnSpan / columnTotal);
  right = left + width;

  CGFloat gutterWidth = columnGutter * gridWidth / 2.0;
  CGFloat gutterHeight = rowGutter * gridHeight / 2.0;

  CGRect frame = CGRectMake(
    left + gutterWidth,
    top + gutterHeight,
    width - (2 * gutterWidth),
    height - (2 * gutterHeight));

  return frame;
}

///---------------------------
/// @name Touch Helper Methods
///---------------------------

/**
  Handles when a touch starts or continues.

  Moves the highlight to the control in the touched grid.

  @param touch Information about the touch, including such information as the location.
 */
- (void)handleTouch:(UITouch *)touch {
  CGPoint pos = [touch locationInView:self];
  BOOL buttonFound = NO;

  for (UIView *view in _layoutProps.keyEnumerator) {
    if ([view isKindOfClass:[UIButton class]]) {
      UIButton *button = (UIButton *)view;

      // is the touch in the ui element?
      if (CGRectContainsPoint(button.frame, pos)) {
        // if not the current button, unhighlight the old and highlight the new
        if (button != _currentChild) {
          [self clearCurrentButton];
          _currentChild = button;
          [button setHighlighted:YES];
        }

        // done processing buttons
        buttonFound = YES;
        break;
      }
    }
  }

  // no button found
  if (! buttonFound) {
    [ self clearCurrentButton];
  }
}

/**
 Handles when a touch is lifted.

 Clears any UI state, and if the selected control was a button, send it a touch event.

 @param touch Information about the touch, including such information as the location.
 */
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

/**
  Halts touch processing and resets UI state.
 */
- (void)clearTouches {
  [self clearCurrentButton];
}

/**
  Resets the UI state, restoring the last interacted child to a non-highighted state.
 */
- (void)clearCurrentButton {
  if (_currentChild) {
    [_currentChild setHighlighted:NO];
    _currentChild = nil;
  }
}

///-------------------------
/// @name Debug Draw Methods
///-------------------------

/**
  Helper method to perform debug drawing to help visualize the cell layout.

  @param ctx The current context to use for drawing.
 */
- (void)debugDrawInContext:(CGContextRef)ctx {

  setStrokeColor(ctx, UIColor.systemOrangeColor);

  CGContextBeginPath(ctx);

  CGFloat rowTotal = _rows;
  CGFloat columnTotal = _columns;
  CGFloat width = self.frame.size.width;
  CGFloat height = self.frame.size.height;

  // draw row dividers
  CGFloat rowOffset = 0.0;
  for (int i = 0; i < _rows - 1; ++i) {
    rowOffset += 1.0;
    CGFloat y = (rowOffset / rowTotal) * height;
    CGContextMoveToPoint(ctx, 0, y);
    CGContextAddLineToPoint(ctx, width, y);
  }

  // draw column dividers
  CGFloat columnOffset = 0.0;
  for (int i = 0; i < _columns - 1; ++i) {
    columnOffset += 1.0;
    CGFloat x = (columnOffset / columnTotal) * width;
    CGContextMoveToPoint(ctx, x, 0);
    CGContextAddLineToPoint(ctx, x, height);
  }

  CGContextClosePath(ctx);
  CGContextDrawPath(ctx, kCGPathStroke);

  // draw gutters
  setStrokeColor(ctx, UIColor.systemGreenColor);

  CGContextBeginPath(ctx);

  if (_rowGutter > 0) {
    CGFloat gutterSize = _rowGutter * height / 2.0;
    CGFloat rowOffset = 0.0;
    for (int i = 0; i < _rows - 1; ++i) {
      rowOffset += 1.0;
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

  if (_columnGutter > 0) {
    CGFloat gutterSize = _columnGutter * width / 2.0;
    CGFloat columnOffset = 0.0;
    for (int i = 0; i < _columns - 1; ++i) {
      columnOffset += 1.0;
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

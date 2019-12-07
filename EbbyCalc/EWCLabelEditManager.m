//
//  EWCLabelEditManager.m
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/13/19.
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

#import "EWCLabelEditManager.h"

@interface EWCLabelEditManager () {
  UIGestureRecognizer *_pressRecognizer;  // gesture recognizer to handle long presses
  UISwipeGestureRecognizer *_swipeRecognizer;  // the gesture recognizer for left swipes to backspace
}
@end

@implementation EWCLabelEditManager

/**
  Property setter for managedLabel.

  Cleans up the gestures recognizer for any previous label, then registers it on the new one.

  @param managedLabel The `UILabel` for which to provide gesture recognition functionality.
 */
- (void)setManagedLabel:(UILabel *)managedLabel {
  // do nothing if this is the same label
  if (managedLabel == _managedLabel) { return; }

  [self cleanupLabel];
  _managedLabel = managedLabel;
  [self setupLabel];
}

/**
  Creates a gesture recognizer if needed, and configures it on the managed label.

  Does nothing if the managed label is not set.
 */
- (void)setupLabel {
  // do nothing if we have no current label
  if (! _managedLabel) { return; }

  if (! _pressRecognizer) {
    _pressRecognizer = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self action:@selector(labelPressed:)];
  }

  if (! _swipeRecognizer) {
    _swipeRecognizer = [[UISwipeGestureRecognizer alloc]
      initWithTarget:self action:@selector(labelSwiped:)];
    _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  }

  [_managedLabel addGestureRecognizer:_pressRecognizer];
  [_managedLabel addGestureRecognizer:_swipeRecognizer];
  [_managedLabel setUserInteractionEnabled:YES];
}

/**
 Removes gesture recognition handling from the current managed label.

 Does nothing if the managed label is not set.
*/
- (void)cleanupLabel {
  // do nothing if we have no current label
  if (! _managedLabel) { return; }

  [_managedLabel setUserInteractionEnabled:NO];
  [_managedLabel removeGestureRecognizer:_swipeRecognizer];
  [_managedLabel removeGestureRecognizer:_pressRecognizer];
}

/**
  Brings up the edit menu in response to a long press.

  The menu uses the informal `UIResponderStandardEditActions` in order to query the supplied control for, and to carry out supported operations.

  @param sender The source of the press gesture.
 */
- (void)labelPressed:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    // setup up copy paste menu for the label
    [_managedLabel becomeFirstResponder];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.arrowDirection = UIMenuControllerArrowDefault;
    CGPoint pressLocation = [sender locationInView:_managedLabel];
    CGRect rect = CGRectMake(pressLocation.x, pressLocation.y, 0, 0);
    [menu showMenuFromView:_managedLabel rect:rect];
  }
}

/**
  Invokes the externally registered block in response to the swipe.

  We expect this to be used to perform a backspace operation on user input.

  @param sender The source of the swipe gesture.
 */
- (void)labelSwiped:(UISwipeGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    if (_swipeHandler) {
      _swipeHandler(_managedLabel, sender.direction);
    }
  }
}

@end

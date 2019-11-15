//
//  EWCLabelEditManager.m
//  HomeCalculator
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
#import <UIKit/UIKit.h>

@interface EWCLabelEditManager () {
  UIGestureRecognizer *_tapRecognizer;
  UIGestureRecognizer *_pressRecognizer;
}
@end

@implementation EWCLabelEditManager

- (void)setManagedLabel:(UILabel *)managedLabel {
  if (managedLabel == _managedLabel) { return; }

  [self cleanupLabel];
  _managedLabel = managedLabel;
  [self setupLabel];
}

- (void)setupLabel {
  if (! _tapRecognizer) {
    _tapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(labelTapped:)];
  }

  if (! _pressRecognizer) {
    _pressRecognizer = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self action:@selector(labelPressed:)];
  }

  [_managedLabel addGestureRecognizer:_tapRecognizer];
  [_managedLabel addGestureRecognizer:_pressRecognizer];
  [_managedLabel setUserInteractionEnabled:YES];
}

- (void)cleanupLabel {
  [_managedLabel removeGestureRecognizer:_tapRecognizer];
  [_managedLabel removeGestureRecognizer:_pressRecognizer];
}

- (void)labelTapped:(UITapGestureRecognizer *)sender {}

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

@end

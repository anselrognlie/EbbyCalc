//
//  EWCCopyableLabel.m
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

#import "EWCCopyableLabel.h"
#import "EWCEditDelegate.h"

@interface EWCCopyableLabel() {
}

@end

@implementation EWCCopyableLabel

- (BOOL)canBecomeFirstResponder {
  return YES;
}

// report the UIResponderStandardEditActions that are supported
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(copy:)) {
    return YES;
  }

  if (action == @selector(paste:)) {
    return YES;
  }

  return [super canPerformAction:action withSender:sender];
}

// implementation of UIResponderStandardEditActions

- (void)copy:(id)sender {
  NSString *text = self.text;

  if (_editDelegate) {
    text = [_editDelegate viewWillCopyText:text];
  }

  if (text) {
    [[UIPasteboard generalPasteboard] setString:text];
  }
}

- (void)paste:(id)sender {
  NSString *text = [UIPasteboard generalPasteboard].string;
  if (_editDelegate) {
    text = [_editDelegate viewWillPasteText:text];
  }

  if (text) {
    self.text = text;
  }
}

@end

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
#import <MobileCoreServices/MobileCoreServices.h>

@interface EWCCopyableLabel() {
}

@end

@implementation EWCCopyableLabel

///----------------------------------------------------------------------
/// @name UIResponderStandardEditActions Informal Protocol Implementation
///----------------------------------------------------------------------

/**
  Indicate that this control can receive focus.
 */
- (BOOL)canBecomeFirstResponder {
  return YES;
}

/**
  Report that this control supports copy and paster operations.

  @param action The action being queried for as a selector.
  @param sender The entity making the query.  Ignored.

  @return YES if the action is `copy:` or `paste:`.  NO otherwise.
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(copy:)) {
    return YES;
  }

  if (action == @selector(paste:)) {
    return YES;
  }

  return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender {
  NSString *text = self.text;

  if (_editDelegate) {
    text = [_editDelegate willCopyText:text withSender:self];
  }

  if (text) {
    [[UIPasteboard generalPasteboard] setValue:text forPasteboardType:(NSString *)kUTTypeUTF8PlainText];
  }
}

- (void)paste:(id)sender {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

  if (pasteboard.hasStrings) {
    NSString *text = pasteboard.string;
    if (_editDelegate) {
      text = [_editDelegate willPasteText:text withSender:self];
    }

    if (text) {
      self.text = text;
    }
  }
}

@end

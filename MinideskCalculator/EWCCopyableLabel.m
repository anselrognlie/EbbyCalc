//
//  EWCCopyableLabel.m
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/13/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

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

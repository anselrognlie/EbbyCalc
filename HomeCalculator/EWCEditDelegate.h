//
//  EWCEditDelegate.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
  `EWCEditDelegate` provides messages that a particular view is about to copy or paste.

  The delegate implementation can customize the copy or paste behavior by responding to the delegate messages.
 */
@protocol EWCEditDelegate <NSObject>

/**
 This message is received just before text from the sending view will be added to the clipboard.  The delegate can intercept this message and modify the string to be copied, or return nil to halt the copy operation entirely.

 @param text The string to be placed on the clipboard.
 @param sender The entity that is the source of the copy operation.

 @return The text that should be placed on the clipboard.  Return nil to halt the copy entirely.
*/
- (nullable NSString *)willCopyText:(NSString *)text withSender:(id)sender;

/**
 This message is received just before text from the clipboard is written to a view.  The delegate can intercept this message and modify the string to be pasted, or return nil to halt the paste operation entirely.

 @param text The string from the clipboard that will be written to the view.
 @param sender The entity that is the target of the paste operation.

 @return The text that should be written to the target.  Return nil to halt the paste entirely.
*/
- (nullable NSString *)willPasteText:(NSString *)text withSender:(id)sender;

@end

NS_ASSUME_NONNULL_END

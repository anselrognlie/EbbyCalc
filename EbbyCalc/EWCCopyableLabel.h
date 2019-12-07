//
//  EWCCopyableLabel.h
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

#import <UIKit/UIKit.h>

@protocol EWCEditDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
  Extends UILabel to implement the informal `UIResponderStandardEditActions` protocol, with support for a delegate to customize the behavior.
 */
@interface EWCCopyableLabel : UILabel

/**
  A delegate to customize response to copy and paste operations.
 */
@property (nonatomic, weak) id<EWCEditDelegate> editDelegate;

/**
  Tells the control to perform a copy operation.

  The default implementation just takes the displayed text, then gives a registered delegate the opportunity to customize the behavior before writing the value to the clipboard.

  @param sender The entity initiating the copy operation.  Ignored.
 */
- (void)copy:(nullable id)sender;

/**
  Tells the control to perform a paste operation.

  The default implementation just reads the clipboard, then gives a registered delegate the opportunity to customize the behavior before updating the displayed text.

  @param sender The entity initiating the copy operation.  Ignored.
 */
- (void)paste:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END

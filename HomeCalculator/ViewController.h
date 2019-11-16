//
//  ViewController.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 10/23/19.
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
#import "EWCEditDelegate.h"

/**
  `ViewController` is the main `UIViewController` class for the app.

  ## Implemented Protocols

  `ViewController` implements `EWCEditDelegate` so that it can respond to copy and paste activity from the UI's numeric display.
 */
@interface ViewController : UIViewController <EWCEditDelegate>

/**
  Handles notifications that the contents of the numeric display should be copied.

  @param text The text contents of the numeric display. Note that we will actually ignore this value and just take the undecorated numeric value directly.

  @return The text that should be placed on the clipboard.  We will return a generically serialized version of the calculator display contents, rather than the decorated display content.
 */
- (nonnull NSString *)viewWillCopyText:(nonnull NSString *)text;

/**
 Handles notifications that the contents of the numeric display should be replaced with the clipboard contents.

 @param text The text from the clipboard.

 @return We always return nil, as we will attempt to interpret the text as a number, and then update the calculator input directly.  Nil will prevent the display label from updating its contents directly.
*/
- (nonnull NSString *)viewWillPasteText:(nonnull NSString *)text;

@end


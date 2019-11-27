//
//  EWCLabelEditManager.h
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EWCLabelSwipedHandler)(UILabel *label, UISwipeGestureRecognizerDirection direction);

/**
  `EWCLabelEditManager` provides gesture recognition management for a UILabel that supports edit operations.
 */
@interface EWCLabelEditManager : NSObject

/**
  The UILabel to which to provide gesture recognition.
 */
@property (nonatomic, weak) UILabel *managedLabel;

/**
  Handler to be called in response to a swipe gesture.
 */
@property (nonatomic, copy) EWCLabelSwipedHandler swipeHandler;

@end

NS_ASSUME_NONNULL_END

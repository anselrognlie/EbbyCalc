//
//  EWCKeyCommandCalculatorRecord.h
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/28/19.
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
#import "EWCCalculatorKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface EWCKeyCommandCalculatorRecord : NSObject

/**
  The parameters of the key command we want to trigger on.
 */
@property (nonatomic, readonly) UIKeyCommand *command;

/**
  The calculator key theu key command should trigger.
 */
@property (nonatomic, readonly) EWCCalculatorKey calculatorKey;

/**
  Creates a new mapping record.

  @param command The keyboard command settings we want to trigger on.
  @param key The calculator key that should be triggered by the keyboard key.

  @return The new mapping record.
 */
+ (instancetype)recordWithCommand:(UIKeyCommand *)command calculatorKey:(EWCCalculatorKey)key;

/**
 Initializes a new mapping record.

 @param command The keyboard command settings we want to trigger on.
 @param key The calculator key that should be triggered by the keyboard key.

 @return The initialized mapping record.
*/
- (instancetype)initWithCommand:(UIKeyCommand *)command calculatorKey:(EWCCalculatorKey)key;

@end

NS_ASSUME_NONNULL_END

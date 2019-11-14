//
//  EWCLabelEditManager.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/13/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UILabel;

NS_ASSUME_NONNULL_BEGIN

@interface EWCLabelEditManager : NSObject

@property (nonatomic, weak) UILabel *managedLabel;

@end

NS_ASSUME_NONNULL_END

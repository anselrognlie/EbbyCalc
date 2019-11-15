//
//  EWCCopyableLabel.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/13/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EWCEditDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface EWCCopyableLabel : UILabel

@property (nonatomic, weak) id<EWCEditDelegate> editDelegate;

@end

NS_ASSUME_NONNULL_END

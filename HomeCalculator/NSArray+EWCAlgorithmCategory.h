//
//  NSArray+EWCAlgorithmCategory.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 11/7/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (EWCAlgorithmCategory)

- (CGFloat)ewc_totalDouble;
- (CGFloat)ewc_minDouble;

@end

NS_ASSUME_NONNULL_END

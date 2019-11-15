//
//  EWCRoundedCornerButton.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 10/23/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EWCRoundedCornerButton : UIButton

@property (nonatomic) UIColor *highlightedBackgroundColor;
@property (nonatomic) NSInteger cornerRadius;

+ (instancetype)buttonLabeled:(NSString *)label colored:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

- (instancetype)initWithLabel:(NSString *)label color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END
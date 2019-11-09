//
//  EWCGridLayoutRoundedButton.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/9/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "EWCRoundedCornerButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface EWCAccessibleRoundedCornerButton : EWCRoundedCornerButton

+ (instancetype)buttonLabeled:(NSString *)label colored:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

- (instancetype)initWithLabel:(NSString *)label color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END

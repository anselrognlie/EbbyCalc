//
//  EWCRoundedCornerButton.h
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/23/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface EWCRoundedCornerButton : UIButton

@property (nonatomic) UIColor *highlightedBackgroundColor;
@property (nonatomic) NSInteger cornerRadius;

//@property (nonatomic) IBInspectable NSInteger cornerRadius;
+ (instancetype)buttonLabeled:(NSString *)label colored:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;


@end

NS_ASSUME_NONNULL_END

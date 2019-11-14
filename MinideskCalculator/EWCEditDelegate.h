//
//  EWCEditDelegate.h
//  MinideskCalculator
//
//  Created by Ansel Rognlie on 11/13/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EWCEditDelegate <NSObject>

- (NSString *)viewWillCopyText:(NSString *)text;
- (NSString *)viewWillPasteText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END

//
//  ViewController.h
//  HomeCalculator
//
//  Created by Ansel Rognlie on 10/23/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWCEditDelegate.h"

@interface ViewController : UIViewController <EWCEditDelegate>

- (nonnull NSString *)viewWillCopyText:(nonnull NSString *)text;
- (nonnull NSString *)viewWillPasteText:(nonnull NSString *)text;

@end


//
//  ShuffleViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+PlanCRUD.h"

@protocol ShuffleViewControllerDelegate <NSObject>
@optional
- (void)didFinishSelectingImage:(UIImage *)image forPlan:(Plan *)plan;
@end

@interface ShuffleViewController : UIViewController
@property (nonatomic,weak) id <ShuffleViewControllerDelegate> svcDelegate;
@end

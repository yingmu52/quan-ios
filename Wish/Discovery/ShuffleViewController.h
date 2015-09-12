//
//  ShuffleViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+PlanCRUD.h"

@class ShuffleViewController;
@protocol ShuffleViewControllerDelegate <NSObject>
@optional
- (void)didFinishSelectingImages:(NSArray *)images forPlan:(Plan *)plan;
- (void)didPressCreatePlanButton:(ShuffleViewController *)svc;
@end

@interface ShuffleViewController : UIViewController
@property (nonatomic,weak) id <ShuffleViewControllerDelegate> svcDelegate;
@end

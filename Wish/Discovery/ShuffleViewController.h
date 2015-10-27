//
//  ShuffleViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
#import "DiscoveryVCData.h"
#import "MSSuperViewController.h"
@class ShuffleViewController;
@protocol ShuffleViewControllerDelegate <NSObject>
@optional

/**
 * 加号浮层回调函数，当选成完多图后委托该方法
 * @param assets 选择多图完成后返回的 PHAsset 数组
 * @param plan 用户选择的事件
 */
- (void)didFinishSelectingImageAssets:(NSArray *)assets forPlan:(Plan *)plan;


/**
 * 加号浮层回调函数，当用户选择添加新事件按扭后回调该函数
 * @param svc 加号浮层控制器
 */
- (void)didPressCreatePlanButton:(ShuffleViewController *)svc;
@end


/**
 `ShuffleViewController` 加号浮层控制器，通过发现页，我的事儿页的加号触发
 */
@interface ShuffleViewController : MSSuperViewController

/**
 svcDelegate 加号浮层的委托对象
 */
@property (nonatomic,weak) id <ShuffleViewControllerDelegate> svcDelegate;
@end

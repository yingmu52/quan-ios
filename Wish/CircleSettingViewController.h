//
//  CircleSettingViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-04.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

@import UIKit;
#import "Circle.h"

@class CircleSettingViewController;
@protocol CircleSettingViewControllerDelegate <NSObject>
- (void)didFinishDeletingCircle;
@end
@interface CircleSettingViewController : UITableViewController
@property (nonatomic,weak) Circle *circle;
@property (nonatomic,weak) id <CircleSettingViewControllerDelegate> delegate;
@end

//
//  MainTabBarController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MainTabBarController.h"
#import "SystemUtil.h"
@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect tabFrame = self.tabBar.frame;
    CGFloat height = 60.0f;
    tabFrame.size.height = height;
    tabFrame.origin.y = self.view.frame.size.height - height;
    self.tabBar.frame = tabFrame;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [[UITabBar appearance] setTintColor:[SystemUtil colorFromHexString:@"#01C1A8"]];
}
@end

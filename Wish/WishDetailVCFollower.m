//
//  WishDetailVCFollower.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCFollower.h"
@implementation WishDetailVCFollower

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.headerView.followButton.hidden = NO;
}

- (void)didFinishUnFollowingPlan:(Plan *)plan{
    
    [super didFinishUnFollowingPlan:plan];
    
    // 1. change plan isFollow Flag
    plan.isFollowed = @(NO);
    // 2. Pop view controller to main following page !
    [self.navigationController popViewControllerAnimated:YES];
}
@end

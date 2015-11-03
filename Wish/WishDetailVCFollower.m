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

- (NSString *)segueForFeed{
    return @"showFollowingFeedDetail";
}
@end

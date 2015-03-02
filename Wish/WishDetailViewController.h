//
//  WishDetailViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FirstTableViewController.h"
#import "Plan.h"
#import "Theme.h"
#import "WishDetailCell.h"
#import "SystemUtil.h"
#import "Feed+FeedCRUD.h"
#import "UIImage+ImageEffects.h"

@interface WishDetailViewController : FirstTableViewController
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC; //fetching Feed
@property (nonatomic,strong) Plan *plan; //must set
- (void)setUpNavigationItem;
- (UIColor *)currenetBackgroundColor;
@end

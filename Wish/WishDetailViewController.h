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
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "UIActionSheet+Blocks.h"

@interface WishDetailViewController : FirstTableViewController <NSFetchedResultsControllerDelegate,WishDetailCellDelegate,FetchCenterDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC; //fetching Feed
@property (nonatomic,strong) Plan *plan; //must set
@property (nonatomic,strong) FetchCenter *fetchCenter;
- (void)setUpNavigationItem;
- (void)updateHeaderView;
- (void)setupBadageImageView;
- (void)loadMore; // abstract


- (void)fetchResultsControllerDidInsert;
@end

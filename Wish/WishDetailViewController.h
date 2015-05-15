//
//  WishDetailViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

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
#import "HeaderView.h"
#import "FeedDetailViewController.h"
@interface WishDetailViewController : UITableViewController <NSFetchedResultsControllerDelegate,WishDetailCellDelegate,FetchCenterDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC; //fetching Feed
@property (nonatomic,strong) Plan *plan; //must set
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) HeaderView *headerView;

/*
 these two properties are for paging feature
 */

@property (nonatomic) BOOL hasNextPage;
@property (nonatomic,strong) NSDictionary *pageInfo;

- (void)setUpNavigationItem;
- (void)updateHeaderView;
- (void)fetchResultsControllerDidInsert;

#pragma mark - abstract
- (NSString *)segueForFeed;

@end

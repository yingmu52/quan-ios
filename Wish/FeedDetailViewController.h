//
//  FeedDetailViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "Theme.h"
#import "FeedDetailCell.h"
#import "FetchCenter.h"
#import "Theme.h"
#import "AppDelegate.h"
#import "UIImageView+ImageCache.h"
#import "Feed+FeedCRUD.h"
#import "SDWebImageCompat.h"
#import "PopupView.h"
#import "FeedDetailHeader.h"

@interface FeedDetailViewController : UITableViewController <FetchCenterDelegate,NSFetchedResultsControllerDelegate,FeedDetailHeaderDelegate>
@property (nonatomic,strong) NSString *feedId; //for Message List View
@property (strong, nonatomic) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) Feed *feed;
@property (nonatomic) BOOL hasNextPage;
@property (nonatomic,strong) NSDictionary *pageInfo;
@property (nonatomic,strong) FeedDetailHeader *headerView;

- (void)setUpNavigationItem;
- (void)loadComments;
@end

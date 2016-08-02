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
#import "Feed.h"
#import "UIImage+ImageEffects.h"
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "HeaderView.h"
#import "FeedDetailViewController.h"
#import "UIImageView+ImageCache.h"
#import "MSSuperViewController.h"
@interface WishDetailViewController : MSSuperViewController <NSFetchedResultsControllerDelegate,WishDetailCellDelegate>
@property (nonatomic,weak) Plan *plan; //must set
@property (nonatomic,strong) HeaderView *headerView;
- (void)setUpNavigationItem;

#pragma mark - abstract
- (NSString *)segueForFeed; //must set to display feed detail

@end

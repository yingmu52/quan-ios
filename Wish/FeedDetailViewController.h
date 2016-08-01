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
#import "SDWebImageCompat.h"
#import "FeedDetailHeader.h"
#import "MSSuperViewController.h"

@interface FeedDetailViewController : MSSuperViewController <FeedDetailHeaderDelegate>
@property (nonatomic,strong) NSString *feedId; //for Message List View
@property (nonatomic,strong) Feed *feed;
@property (nonatomic,strong) FeedDetailHeader *headerView;
- (void)setUpNavigationItem;

@end

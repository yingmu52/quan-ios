//
//  FollowingCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingCell.h"
#import "SystemUtil.h"
#import "AppDelegate.h"
#import "FollowingImageCell.h"
#import "Feed.h"
#import "UIImageView+WebCache.h"
#import "FetchCenter.h"
@import CoreData;

static NSUInteger numberOfPreloadedFeeds = 3;


@interface FollowingCell () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *feedBackground;
@property (weak, nonatomic) IBOutlet UIView *headBackground;
@property (nonatomic,strong) NSArray *feedsArray;
@end
@implementation FollowingCell

- (IBAction)loadMore:(UIButton *)sender{
    [self.delegate didPressMoreButtonForCell:self];
}

- (void)setPlan:(Plan *)plan{
    _plan = plan;
    NSArray *feeds = _plan.feeds.allObjects;
    if (_plan.feeds.count > numberOfPreloadedFeeds) {
        self.feedsArray = [_plan.feeds.allObjects subarrayWithRange:NSMakeRange(0, numberOfPreloadedFeeds)];
    }else{
        self.feedsArray = [feeds mutableCopy];
    }
}

#pragma mark - collection view delegate and data source
-(FollowingImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FollowingImageCell *cell;
    if (indexPath.row == self.feedsArray.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:FOLLOWINGIMAGECELLLASTID
                                                                             forIndexPath:indexPath];
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:FOLLOWINGIMAGECELLID
                                                                             forIndexPath:indexPath];
        Feed *feed = self.feedsArray[indexPath.row];
        NSAssert(feed.imageId, @"null feed image id");
        [cell.feedImageView sd_setImageWithURL:[[FetchCenter new] urlWithImageID:feed.imageId]
                              placeholderImage:[UIImage imageNamed:@"snow.jpg"]];
        
    }
    return cell;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.feedsArray.count+1;
}

#pragma mark - UI

- (void)setCollectionView:(UICollectionView *)collectionView{
    _collectionView = collectionView;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    
}


- (void)setFeedBackground:(UIView *)feedBackground{
    _feedBackground = feedBackground;
    [SystemUtil setupShawdowForView:_feedBackground];
}

- (void)setHeadBackground:(UIView *)headBackground{
    _headBackground = headBackground;
    _headBackground.backgroundColor = [UIColor whiteColor];
    [SystemUtil setupShawdowForView:_headBackground];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat side = collectionView.bounds.size.height;
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        return CGSizeMake(side*190.0/350, side);
    }
    return CGSizeMake(side,side);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    CGFloat margin = self.collectionView.frame.size.width*14.0/610.0;
    return UIEdgeInsetsMake(0, margin, 0, margin);
}



@end

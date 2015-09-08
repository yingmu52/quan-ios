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
#import "UIImageView+ImageCache.h"
#import "FetchCenter.h"
@import CoreData;
@import QuartzCore;

@interface FollowingCell () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *feedBackground;
@property (weak, nonatomic) IBOutlet UIView *headBackground;
@end
@implementation FollowingCell

- (void)setFeedsArray:(NSArray *)feedsArray{
    _feedsArray = feedsArray;
    Feed *feed = _feedsArray.firstObject;
    self.bottomLabel.text = feed.feedTitle;
    [self.collectionView reloadData];
}

- (IBAction)loadMore:(UIButton *)sender{
    [self.delegate didPressMoreButtonForCell:self];
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

        NSURL *imageUrl = [[FetchCenter new] urlWithImageID:feed.imageId size:FetchCenterImageSize400];
        [cell.feedImageView showImageWithImageUrl:imageUrl];
    }
    return cell;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.feedsArray.count+1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.feedsArray.count) return;
    [self.delegate didPressCollectionCellAtIndex:indexPath forCell:self];
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
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowOpacity = 0.15f;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);

}



//- (void)setFeedBackground:(UIView *)feedBackground{
//    _feedBackground = feedBackground;
//    [SystemUtil setupShawdowForView:_feedBackground];
//}

//- (void)setHeadBackground:(UIView *)headBackground{
//    _headBackground = headBackground;
//    _headBackground.backgroundColor = [UIColor whiteColor];
//    [SystemUtil setupShawdowForView:_headBackground];
//}


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


#pragma mark - tap on user profile picture 

- (IBAction)userProfilePictureTapped{
//    [self.delegate didTapOnProfilePicture:self];
}

@end

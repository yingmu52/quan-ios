//
//  FollowingCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingCell.h"

@interface FollowingCell () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *feedBackground;
@property (weak, nonatomic) IBOutlet UIView *headBackground;
@property (weak, nonatomic) IBOutlet UILabel *headTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *headUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *wishDetailCollectionView;

@end
@implementation FollowingCell


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedInFollowingCell" forIndexPath:indexPath];
    
    return cell;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 4;
}
- (void)setWishDetailCollectionView:(UICollectionView *)wishDetailCollectionView{
    _wishDetailCollectionView = wishDetailCollectionView;
    _wishDetailCollectionView.dataSource = self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}
- (void)setupShawdowForView:(UIView *)view{
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowRadius = 1.0f;
    view.layer.shadowOpacity = 0.15f;
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)setFeedBackground:(UIView *)feedBackground{
    _feedBackground = feedBackground;
    [self setupShawdowForView:_feedBackground];
}

- (void)setHeadBackground:(UIView *)headBackground{
    _headBackground = headBackground;
    _headBackground.backgroundColor = [UIColor whiteColor];
    [self setupShawdowForView:_headBackground];
}

@end

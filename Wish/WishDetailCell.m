//
//  WishDetailCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailCell.h"
#import "SystemUtil.h"
#import "Theme.h"
#import "AppDelegate.h"
@interface WishDetailCell()
@end
@implementation WishDetailCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];

}

- (void)setFeed:(Feed *)feed
{
    _feed = feed;
    self.photoView.image = feed.image;
    self.dateLabel.text = [SystemUtil stringFromDate:feed.createDate];

    [self.likeButton setImage:feed.selfLiked.boolValue ? [Theme likeButtonLiked] : [Theme likeButtonUnLiked]
                     forState:UIControlStateNormal];
    
    self.titleLabel.text = feed.feedTitle;
}

//- (void)setPhotoView:(UIImageView *)photoView
//{
//    _photoView = photoView;
    //crop the feed image to display properly
//    _photoView.contentMode = UIViewContentModeScaleAspectFill;
//    _photoView.clipsToBounds = YES;
//}

- (IBAction)like:(UIButton *)sender{
    
    if (self.feed.selfLiked.boolValue){
        self.feed.selfLiked = @(NO);
        self.feed.likeCount = @(self.feed.likeCount.integerValue - 1);
    }else{
        self.feed.selfLiked = @(YES);
        self.feed.likeCount = @(self.feed.likeCount.integerValue + 1);
    }
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveContext];
    [self.delegate didPressedLikeOnCell:self];
}

- (IBAction)morePressed:(UIButton *)sender{
    [self.delegate didPressedMoreOnCell:self];
}
@end

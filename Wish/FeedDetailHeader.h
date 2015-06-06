//
//  FeedDetailHeader.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-05.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedDetailHeader;

@protocol FeedDetailHeaderDelegate
- (void)didPressedLikeButton:(FeedDetailHeader *)headerView;
- (void)didPressedCommentButton:(FeedDetailHeader *)headerView;
@end
@interface FeedDetailHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel* headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;


@property (nonatomic,weak) id <FeedDetailHeaderDelegate> delegate;

+ (instancetype)instantiateFromNib:(CGRect)frame;
@end

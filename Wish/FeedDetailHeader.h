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
- (void)didTapOnImageView:(UIImageView *)imageView;
@end
@interface FeedDetailHeader : UIView <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic,weak) id <FeedDetailHeaderDelegate> delegate;

+ (instancetype)instantiateFromNib:(CGRect)frame;

- (void)setLikeButtonText:(NSString *)text;
- (void)setCommentButtonText:(NSString *)text;
@end

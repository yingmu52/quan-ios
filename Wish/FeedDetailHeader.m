//
//  FeedDetailHeader.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-05.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailHeader.h"
#import "FetchCenter.h"
#import "UIImageView+ImageCache.h"

@interface FeedDetailHeader ()

@end
@implementation FeedDetailHeader

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    FeedDetailHeader *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    return view;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.scrollView.delegate = self;
}

- (IBAction)likeButtonPressed{
    [self.delegate didPressedLikeButton:self];
}

- (IBAction)commentButtonPressed{
    [self.delegate didPressedCommentButton:self];
}

- (IBAction)didTapOnScrollView:(UITapGestureRecognizer *)tap{
    UIImageView *imageView = [self.scrollView.subviews objectAtIndex:self.pageControl.currentPage];
    [self.delegate didTapOnImageView:imageView];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;;
}

- (void)setLikeButtonText:(NSNumber *)count{
    NSString *text = count.integerValue ? [NSString stringWithFormat:@"%@",count] : @"赞";
    [self.likeButton setTitle:[text stringByAppendingString:@" "] forState:UIControlStateNormal];
    [self.likeButton sizeToFit];
}

- (void)setCommentButtonText:(NSNumber *)count{
    NSString *text = count.integerValue ? [NSString stringWithFormat:@"%@",count] : @"评论";
    [self.commentButton setTitle:[text stringByAppendingString:@" "] forState:UIControlStateNormal];
}

- (IBAction)longpressOnLabel:(UILongPressGestureRecognizer *)longpress{
    [self.titleTextLabel handleLongpress:longpress];
}

- (IBAction)tapOnLabel:(UITapGestureRecognizer *)tap{
    [self.titleTextLabel resetNormalState];
}


@end

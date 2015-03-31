//
//  WishDetailCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailCell.h"
#import "SystemUtil.h"
@interface WishDetailCell()
@end
@implementation WishDetailCell

- (void)awakeFromNib {
    // Initialization code
    self.likeButton.hidden = YES;
    self.likeLabel.hidden = YES;
    self.commentButton.hidden = YES;
    self.commentLabel.hidden = YES;
    self.backgroundColor = [UIColor clearColor];

}

- (void)setTitleTextView:(UITextView *)titleTextView{
    _titleTextView = titleTextView;
    _titleTextView.textContainer.lineFragmentPadding = 0.0f;
    _titleTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)setFeed:(Feed *)feed
{
    _feed = feed;
    self.photoView.image = feed.image;
    self.dateLabel.text = [SystemUtil stringFromDate:feed.createDate];
    self.likeLabel.text = [NSString stringWithFormat:@"%@",feed.likeCount];
    self.commentLabel.text = [NSString stringWithFormat:@"%@",feed.commentCount];
//    self.infoLabel.text = feed.feedTitle;
    self.titleTextView.text = feed.feedTitle;
    [self setNeedsDisplay];
}

- (void)setPhotoView:(UIImageView *)photoView
{
    _photoView = photoView;
    
    //crop the feed image to display properly
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    _photoView.clipsToBounds = YES;
}


//-(void)showLikeAndComment
//{
//    [self moveWidget:YES];
//}
//- (void)dismissLikeAndComment{
//    [self moveWidget:NO];
//}
//
//- (void)moveWidget:(BOOL)toVisible
//{
//    CGFloat offset = toVisible ? self.center.x : -self.center.x;
//    
//    for (UIView *widget in @[self.likeButton,self.commentButton,self.likeLabel,self.commentLabel]) {
//        
//        //move back or away from screen
//        [widget setCenter:CGPointMake(widget.center.x + offset, widget.center.y)];
//        
//        //appear or disappear
//        widget.hidden = !toVisible;
//        
//        [widget setCenter:CGPointMake(widget.center.x - offset, widget.center.y)];
//        
//    }
//}
@end

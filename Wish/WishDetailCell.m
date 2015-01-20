//
//  WishDetailCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailCell.h"
@interface WishDetailCell()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (weak, nonatomic) IBOutlet UILabel *likeLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@end
@implementation WishDetailCell

- (void)awakeFromNib {
    // Initialization code


}

-(void)showLikeAndComment
{
    [self moveWidget:YES];
//    self.likeButton.hidden = YES;
//    self.commentButton.hidden = YES;
//    self.likeLabel.hidden = YES;
//    self.commentLabel.hidden = YES;
}
- (void)dismissLikeAndComment{
    [self moveWidget:NO];
//    self.likeButton.hidden = NO;
//    self.commentButton.hidden = NO;
//    self.likeLabel.hidden = NO;
//    self.commentLabel.hidden = NO;

}

- (void)moveWidget:(BOOL)toVisible
{
    CGFloat offset = toVisible ? self.center.x : -self.center.x;
    
    for (UIView *widget in @[self.likeButton,self.commentButton,self.likeLabel,self.commentLabel]) {
        
        //move back or away from screen
        [widget setCenter:CGPointMake(widget.center.x + offset, widget.center.y)];
        
        //appear or disappear
        widget.hidden = !toVisible;
        
        [widget setCenter:CGPointMake(widget.center.x - offset, widget.center.y)];
        
    }
}
@end

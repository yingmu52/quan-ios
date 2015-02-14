//
//  FollowingCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingCell.h"

@interface FollowingCell ()
@property (weak, nonatomic) IBOutlet UIView *feedBackground;
@property (weak, nonatomic) IBOutlet UIView *headBackground;

@end
@implementation FollowingCell

- (void)awakeFromNib
{
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

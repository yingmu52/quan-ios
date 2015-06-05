//
//  WishDetailCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailCell.h"
@interface WishDetailCell()
@end
@implementation WishDetailCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (IBAction)like:(UIButton *)sender{
    [self.delegate didPressedLikeOnCell:self];
}

- (IBAction)morePressed:(UIButton *)sender{
    [self.delegate didPressedMoreOnCell:self];
}

- (IBAction)commentPressed:(UIButton *)sender{
    [self.delegate didPressedCommentOnCell:self];
}
@end

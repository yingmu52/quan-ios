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
    
    //round corner
    self.pictureCountLabel.layer.cornerRadius = 8;
    self.pictureCountLabel.layer.masksToBounds = YES;
    
}

- (void)setPictureLabelText:(NSString *)text{
    //set left and right margin
    self.pictureCountLabel.text = [NSString stringWithFormat:@" %@ ",text];
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

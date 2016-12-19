//
//  CircleDetailHeader.m
//  Stories
//
//  Created by Xinyi Zhuang on 02/12/2016.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleDetailHeader.h"
#import "UIImageView+ImageCache.h"
#import "SystemUtil.h"
@implementation CircleDetailHeader


- (void)setupHeaderView:(Circle *)circle{

    [self.circleImageView downloadImageWithImageId:circle.mCoverImageId
                                              size:FetchCenterImageSize400];
    self.circleTitleLabel.text = circle.mTitle;
    self.followCountLabel.text = [NSString stringWithFormat:@"%@人关注",circle.nFans];
    
    //circle description
    self.circleDescriptionTextView.text = circle.mDescription;
    
    CGRect frame = self.frame;
    frame.size.height = 220.0f;
    if (circle.mDescription.length > 0){
        CGFloat textViewHeight = [SystemUtil heightForText:self.circleDescriptionTextView.text withFontSize:12.0f];
        frame.size.height += textViewHeight;
    }
    self.frame = frame;

}

- (void)updateFollowButton:(Circle *)circle{
    if (circle.circleType.integerValue == CircleTypeFollowed) {
        [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.followButton.hidden = NO;
        self.followButton.enabled = NO;
        NSLog(@"圈子已经关注");
    }else if (circle.isFollowable.boolValue){
        [self.followButton setTitle:@"关注" forState:UIControlStateNormal];
        self.followButton.hidden = NO;
        self.followButton.enabled = YES;
    }else{
        NSLog(@"圈子不允许被关注");
        self.followButton.hidden = YES;
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.circleImageView.layer.cornerRadius = 5.0f;
    self.circleImageView.clipsToBounds = YES;
    
    self.circleDescriptionTextView.textContainerInset = UIEdgeInsetsZero;
    self.followButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.followButton.layer.borderWidth = 1.0f;
    self.followButton.layer.cornerRadius = 11.0f; // 高的一半
    self.circleDescriptionTextView.textColor = [UIColor whiteColor];
}
@end

//
//  FeedDetailHeader.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-05.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailHeader.h"

@implementation FeedDetailHeader

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    FeedDetailHeader *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    return view;
}


- (IBAction)likeButtonPressed{
    [self.delegate didPressedLikeButton:self];
}

- (IBAction)commentButtonPressed{
    [self.delegate didPressedCommentButton:self];
}
@end

//
//  FeedbackkAccessoryView.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedbackkAccessoryView.h"

@implementation FeedbackkAccessoryView

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    FeedbackkAccessoryView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    [view setNeedsLayout];
    return view;
}

@end

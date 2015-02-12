//
//  KeyboardAcessoryView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "KeyboardAcessoryView.h"

@implementation KeyboardAcessoryView

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    KeyboardAcessoryView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    return view;
}

@end

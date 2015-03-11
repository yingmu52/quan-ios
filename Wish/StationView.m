//
//  StationView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "StationView.h"
#import "UIImage+ImageEffects.h"

@implementation StationView


+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    StationView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    view.backgroundColor = [UIColor blackColor];


    return view;
}



@end

//
//  StationView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "StationView.h"
#import "PopupView.h"


@implementation StationView


+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    StationView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
//    view.backgroundColor = [UIColor orangeColor];

//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
//    imageView.image = [SystemUtil imageFromColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.65]];
//    
//    [view insertSubview:imageView atIndex:0];
    return view;
}

- (void)updateCardViewToLocation:(CGPoint)location
{
    self.cardView.center = location;
}


- (void)setCurrentCardLocation:(CGPoint)currentCardLocation
{
    _currentCardLocation = currentCardLocation;
    [self updateCardViewToLocation:_currentCardLocation];
}
@end

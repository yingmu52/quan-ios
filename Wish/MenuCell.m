//
//  MenuCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell


- (void)setMenuImageView:(UIView *)menuImageView
{
    _menuImageView = menuImageView;
    if (_menuImageView) {
        NSLog(@"no menue image");
    }
    NSLog(@"%@",NSStringFromCGRect(self.menuImageView.frame));
}
@end

//
//  NavigationBar.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE


@interface NavigationBar : UINavigationBar


@property (strong, nonatomic) IBInspectable UIColor *color;

-(void)setNavigationBarWithColor:(UIColor *)color;

//- (void)showDefaultTextColor;
//- (void)showTextWithColor:(UIColor *)color;
//- (void)showClearBackground;
//- (void)showDefaultBackground;
@end

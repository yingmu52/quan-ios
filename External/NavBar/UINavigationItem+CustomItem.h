//
//  UINavigationItem+CustomItem.h
//  CustomBarItemDemo
//
//  Created by wangtian on 14-11-22.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBarItem.h"
@interface UINavigationItem (CustomItem)

- (CustomBarItem *)setItemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(ItemType)type;
- (CustomBarItem *)setItemWithImage:(UIImage *)image size:(CGSize)size itemType:(ItemType)type;
- (CustomBarItem *)setItemWithCustomView:(UIView *)customView itemType:(ItemType)type;
@end

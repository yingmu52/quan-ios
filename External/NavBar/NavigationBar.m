//
//  NavigationBar.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "NavigationBar.h"
@import QuartzCore;
#import "Theme.h"
#import "UINavigationBar+CustomHeight.h"
@implementation NavigationBar

static CGFloat kEndPoint = 1.5;

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    //导航文字属性
    UIColor *color = [SystemUtil colorFromHexString:@"#2B2B2B"];
    self.titleTextAttributes = @{NSForegroundColorAttributeName:color,
                                            NSFontAttributeName:[UIFont systemFontOfSize:17.0]};;

    //背影图
    [self setBackgroundImage:[SystemUtil imageFromColor:[Theme naviBackground] size:CGSizeMake(1,1)]
               forBarMetrics:UIBarMetricsDefault];

    //去掉分隔线
    self.shadowImage = [UIImage new];
    
    //修复iphone6 导航不适配问题
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 44.0);
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

//- (void)showClearBackground{
//    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//}
//
//- (void)showDefaultBackground{
//    [self setBackgroundImage:[SystemUtil imageFromColor:[Theme naviBackground] size:CGSizeMake(1,1)]
//               forBarMetrics:UIBarMetricsDefault];
//}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(rect.size.width/2, 0);
    CGPoint endPoint = CGPointMake(rect.size.width/2, rect.size.height/kEndPoint);
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithGradients:(NSArray *)colours
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * beginColor = [colours objectAtIndex:0];
    UIColor * endColor = [colours objectAtIndex:1];
    drawLinearGradient(context, rect, beginColor.CGColor, endColor.CGColor);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)setNavigationBarWithColor:(UIColor *)color
{
    UIImage *image = [self imageWithColor:color];
    
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self setBarStyle:UIBarStyleDefault];
    [self setShadowImage:[UIImage new]];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self setTintColor:[UIColor whiteColor]];
    [self setTranslucent:YES];
    
}

-(void)setNavigationBarWithColors:(NSArray *)crolours
{
    UIImage *image = [self imageWithGradients:crolours];
    
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self setBarStyle:UIBarStyleDefault];
    [self setShadowImage:[UIImage new]];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self setTintColor:[UIColor whiteColor]];
    [self setTranslucent:YES];
}



@end

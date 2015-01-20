//
//  Theme.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Theme.h"

@implementation Theme

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target
                     selector:(SEL)method
                        frame:(CGRect)frame{
//    CGRect frame = CGRectMake(10, 10, 30, 30);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target
            action:method
  forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:image
         forState:UIControlStateNormal];
    if (!CGRectIsEmpty(frame)) btn.frame = frame;
    return btn;
}
+ (UIImage *)navBackButtonDefault
{
    return [UIImage imageNamed:@"nav-ic-back-default"];
}

+ (UIImage *)navComposeButtonDefault
{
    return [UIImage imageNamed:@"nav-ic-eidt-default"];
}

+ (UIImage *)navShareButtonDefault
{
    return [UIImage imageNamed:@"nav-ic-share-default"];
}
+ (UIImage *)navAddDefault{
    return [UIImage imageNamed:@"nav-ic-add-default"];
}

+ (UIImage *)navMenuDefault{
    return [UIImage imageNamed:@"nav-ic-tab-default"];
}
+ (UIColor *)naviBackground{
    return [[self class] colorfromImg:@"bg-navbar"];
}
+ (UIColor *)homeBackground{
    return [[self class] colorFromHexString:@"#F6FAF9"];
}
+(UIColor *)menuBackground{
    return [[self class] colorfromImg:@"tab-bg"];
}
+ (UIColor *)colorfromImg:(NSString *)name{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:name]];
}
// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end


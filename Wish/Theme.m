//
//  Theme.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015_01_15.
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

+ (UIImage *)wishDetailCameraDefault
{
    return [UIImage imageNamed:@"stop_ic_camera"];
}
+ (UIImage *)navBackButtonDefault
{
    return [UIImage imageNamed:@"nav_ic_back_default"];
}


+ (UIImage *)navTikButtonDefault
{
    return [UIImage imageNamed:@"nav_ic_share_default"];
}

+ (UIImage *)navComposeButtonDefault
{
    return [UIImage imageNamed:@"nav_ic_eidt_default"];
}

+ (UIImage *)navShareButtonDefault
{
    return [UIImage imageNamed:@"nav_ic_share_default"];
}
+ (UIImage *)navAddDefault{
    return [UIImage imageNamed:@"nav_ic_add_default"];
}

+ (UIImage *)navMenuDefault{
    return [UIImage imageNamed:@"nav_ic_tab_default"];
}
+ (UIColor *)naviBackground{
    return [[self class] colorfromImg:@"bg_navbar"];
}
+ (UIColor *)homeBackground{
    return [[self class] colorFromHexString:@"#F6FAF9"];
}
+(UIColor *)menuBackground{
    return [[self class] colorfromImg:@"tab_bg"];
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


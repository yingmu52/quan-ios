//
//  Theme.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015_01_15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "Theme.h"
#import "SystemUtil.h"
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

+ (UIColor *)postTabBorderColor{
    return [UIColor colorWithRed:0.7451 green:0.7765 blue:0.8039 alpha:1.0];
}
+ (UIColor *)privacyBackgroundSelected{
    return [UIColor colorWithRed:0 green:0.8078 blue:0.7176 alpha:1.0];
}

+ (UIColor *)privacyBackgroundDefault{
    return [UIColor whiteColor];
}
+ (UIImage *)privacyIconDefault{
    return [UIImage imageNamed:@"ic_secret_default"];
}

+ (UIImage *)privacyIconSelected{
    return [UIImage imageNamed:@"ic_secret_selected"];
}
+ (UIImage *)tipsBackgroundImage
{
    return [UIImage imageNamed:@"tips_bg"];
}

+ (UIImage *)menuLoginDefault
{
    return [UIImage imageNamed:@"tab_ic_login_default"];
}

+ (UIImage *)menuWishListDefault
{
    return [UIImage imageNamed:@"tab_ic_home_default"];
}

+ (UIImage *)menuWishListSelected
{
    return [UIImage imageNamed:@"tab_ic_home_selected"];
    
}

+ (UIImage *)menuJourneyDefault
{
    return [UIImage imageNamed:@"tab_ic_achieve_default"];
    
}

+ (UIImage *)menuJourneySelected
{
    return [UIImage imageNamed:@"tab_ic_achieve_selected"];
}

+ (UIImage *)menuDiscoverDefault
{
    return [UIImage imageNamed:@"tab_ic_discover_default"];
}

+ (UIImage *)menuDiscoverSelected
{
    return [UIImage imageNamed:@"tab_ic_discover_selected"];
}

+ (UIImage *)menuFollowDefault
{
    return [UIImage imageNamed:@"tab_ic_follow_default"];
}

+ (UIImage *)menuFollowSelected
{
    return [UIImage imageNamed:@"tab_ic_follow_selected"];
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
    return [UIImage imageNamed:@"nav_ic_finish_default"];
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
    return [SystemUtil colorFromHexString:@"#F6FAF9"];
}
+(UIColor *)menuBackground{
    return [[self class] colorfromImg:@"tab_bg"];
}
+ (UIColor *)colorfromImg:(NSString *)name{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:name]];
}

@end


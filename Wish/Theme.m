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

+ (UIColor *)wishDetailBackgroundNone:(UIView *)referenceView{
    UIImage *img = [UIImage imageNamed:@"bg_tile"];
    CGRect frame = referenceView.frame;
    frame.size.height /= 2.0;
    UIImage *tileImage = [SystemUtil darkLayeredImage:img inRect:frame];
    return [UIColor colorWithPatternImage:tileImage];
}

+ (UIImage *)achievementFail{
    return [UIImage imageNamed:@"fail_ic"];
}

+ (UIImage *)achievementFinish{
    return [UIImage imageNamed:@"finish_ic"];
}


+ (UIImage *)wishDetailBackgroundNonLogo{
    return [UIImage imageNamed:@"image_bg"];
}
+ (UIColor *)postTabBorderColor{
    return [UIColor colorWithRed:0.7451 green:0.7765 blue:0.8039 alpha:1.0];
}
+ (UIColor *)privacyBackgroundSelected{
    return [UIColor colorWithRed:0 green:0.8078 blue:0.7176 alpha:1.0];
}

+ (UIColor *)privacyBackgroundDefault{
    return [SystemUtil colorFromHexString:@"#F6FAF9"];
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

+ (UIImage *)navWhiteButtonDefault{
    return [UIImage imageNamed:@"nav_ic_white_default"];
}

+ (UIImage *)navTikButtonDisable{
    return [UIImage imageNamed:@"nav_ic_finish_disable"];
}
+ (UIImage *)navTikButtonDefault
{
    return [UIImage imageNamed:@"nav_ic_finish_default"];
}

+ (UIImage *)navComposeButtonDefault
{
    return [UIImage imageNamed:@"nav_ic_eidt_default"];
}

+ (UIImage *)navButtonDeleted{
    return [UIImage imageNamed:@"nav_delete_ic"];
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
    return [[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_navbar"]] colorWithAlphaComponent:0.95];
}
+ (UIColor *)homeBackground{
    return [SystemUtil colorFromHexString:@"#F6FAF9"];
}
+(UIColor *)menuBackground{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_bg"]];
}


+ (UIImage *)popupFail{
    return [UIImage imageNamed:@"popup_img_fail"];
}

+ (UIImage *)popupFinish{
    return [UIImage imageNamed:@"popup_img_finish"];
}

+ (UIColor *)popupBackground{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"popup_bg"]];
    
}

+ (UIColor *)profileBakground{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile_bg"]];
}


//+ (UIImage *)achieveBadageLabelFail{
//    return [UIImage imageNamed:@"label_fail"];
//}

//+ (UIImage *)achieveBadageLabelSuccess{
//    return [UIImage imageNamed:@"label_finish"];
//}



+ (UIImage *)likeButtonLiked{
    return [UIImage imageNamed:@"ic_like_selected"];
}

+ (UIImage *)likeButtonUnLiked{
    return [UIImage imageNamed:@"ic_like_default"];
}
@end


//
//  Theme.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Theme : UIColor
+ (UIButton *)buttonWithImage:(UIImage *)image
                       target:(id)target
                     selector:(SEL)method
                        frame:(CGRect)frame;


+ (UIColor *)postTabBorderColor;
+ (UIImage *)privacyIconDefault;
+ (UIImage *)privacyIconSelected;
+ (UIColor *)privacyBackgroundSelected;
+ (UIColor *)privacyBackgroundDefault;

+ (UIImage *)menuLoginDefault;
+ (UIImage *)menuWishListDefault;
+ (UIImage *)menuWishListSelected;
+ (UIImage *)menuJourneyDefault;
+ (UIImage *)menuJourneySelected;
+ (UIImage *)menuDiscoverDefault;
+ (UIImage *)menuDiscoverSelected;
+ (UIImage *)menuFollowDefault;
+ (UIImage *)menuFollowSelected;
+ (UIColor *)menuBackground;

+ (UIImage *)navBackButtonDefault;
+ (UIImage *)navComposeButtonDefault;
+ (UIImage *)navShareButtonDefault;
+ (UIColor *)naviBackground;
+ (UIImage *)navMenuDefault;
+ (UIImage *)navAddDefault;
+ (UIImage *)navTikButtonDefault;
+ (UIImage *)navTikButtonDisable;

+ (UIImage *)wishDetailCameraDefault;
+ (UIImage *)wishDetailBackgroundNonLogo;
+ (UIColor *)wishDetailBackgroundNone:(UIView *)referenceView;
+ (UIColor *)homeBackground;
+ (UIImage *)tipsBackgroundImage;
@end

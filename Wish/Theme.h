//
//  Theme.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemUtil.h"
@interface Theme : UIColor

+ (UIColor *)globleColor;
+ (UIColor *)getRandomShortRangeHSBColorWithAlpha:(CGFloat)alpha;

+ (UIButton *)buttonWithImage:(UIImage *)image
                       target:(id)target
                     selector:(SEL)method
                        frame:(CGRect)frame;


+ (UIImage *)likeButtonLiked;
+ (UIImage *)likeButtonUnLiked;
    

+ (UIColor *)postTabBorderColor;
+ (UIImage *)privacyIconDefault;
+ (UIImage *)privacyIconSelected;
+ (UIColor *)privacyBackgroundSelected;
+ (UIColor *)privacyBackgroundDefault;

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
+ (UIImage *)navShareButtonDefault;
+ (UIColor *)naviBackground;
+ (UIImage *)navWhiteButtonDefault;
+ (UIImage *)navMenuDefault;
+ (UIImage *)navTikButtonDefault;
+ (UIImage *)navTikButtonDisable;
+ (UIImage *)navButtonDeleted;
+ (UIImage *)navCircleIcon;
+ (UIImage *)navInviteDefault;
+ (UIImage *)navSettingIcon;
+ (UIImage *)navMoreButtonDefault;
+ (UIImage *)navIconFollowDefault;

+ (UIImage *)wishDetailCameraDefault;
+ (UIImage *)wishDetailBackgroundNonLogo;
+ (UIColor *)wishDetailBackgroundNone:(UIView *)referenceView;
+ (UIColor *)homeBackground;
+ (UIImage *)tipsBackgroundImage;
+ (UIImage *)EditPlanRadioButtonCheckMark;

+ (UIImage *)achievementFail;
+ (UIImage *)achievementFinish;
+ (UIImage *)achieveBadageEmpty;
+ (UIImage *)popupConfirmPressed;
+ (UIImage *)popupFail;
+ (UIImage *)popupFinish;
+ (UIColor *)popupBackground;

+ (UIImage *)topImageMask;
+ (UIColor *)profileBakground;
+ (UIImage *)discoveryAddButton;
+ (UIImage *)tabbarAddButton;
+ (UIImage *)checkmarkSelected;
+ (UIImage *)checkmarkUnSelected;


+ (UIImage *)circleListCheckBoxDefault;
+ (UIImage *)circleListCheckBoxSelected;
+ (UIImage *)circleCreationImageBackground;

+ (UIImage *)circleOwnerIcon;
+ (UIImage *)circleAdminIcon;
@end

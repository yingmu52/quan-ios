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


+ (UIImage *)menuLoginDefault;

+ (UIImage *)menuWishListDefault;

+ (UIImage *)menuWishListSelected;

+ (UIImage *)menuJourneyDefault;

+ (UIImage *)menuJourneySelected;

+ (UIImage *)menuDiscoverDefault;
+ (UIImage *)menuDiscoverSelected;

+ (UIImage *)menuFollowDefault;

+ (UIImage *)menuFollowSelected;

+ (UIImage *)navBackButtonDefault;
+ (UIImage *)navComposeButtonDefault;
+ (UIImage *)navShareButtonDefault;

+ (UIImage *)wishDetailCameraDefault;

+(UIColor *)menuBackground;

+(UIColor *)homeBackground;

+ (UIColor *)naviBackground;

+ (UIImage *)navMenuDefault;

+ (UIImage *)navAddDefault;

+ (UIImage *)navTikButtonDefault;


@end

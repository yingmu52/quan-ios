//
//  PopupView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PopupView.h"
#import "Theme.h"

@implementation PopupView

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    PopupView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    view.backgroundColor = [UIColor clearColor];
    view.popUpBackground.backgroundColor = [Theme popupBackground];
    return view;
}

+ (instancetype)showPopupFinishinFrame:(CGRect)frame{
    PopupView *view = [PopupView instantiateFromNib:frame];
    view.headBannerImageView.image = [Theme popupFinish];
    view.headBannerLabel.text = @"恭喜达成！";
    view.HeadDeleteLabel.text = nil;
    return view;
}
+ (instancetype)showPopupFailinFrame:(CGRect)frame{
    PopupView *view = [PopupView instantiateFromNib:frame];
    view.headBannerImageView.image = [Theme popupFail];
    view.headBannerLabel.text = @"真的放弃？";
    view.HeadDeleteLabel.text = nil;
    return view;
}
+ (instancetype)showPopupDeleteinFrame:(CGRect)frame{
    PopupView *view = [PopupView instantiateFromNib:frame];
    view.headBannerImageView.image = nil;
    view.popUpBackground.backgroundColor = [UIColor whiteColor];
    view.headBannerLabel.text = nil;
    view.HeadDeleteLabel.text = @"删除的卡片不恢复哦！";
    return view;
}

- (IBAction)cancelPressed:(UIButton *)sender {
    [self.delegate popupViewDidPressCancel];
}
- (IBAction)confirmPressed:(UIButton *)sender {
    [self.delegate popupViewDidPressConfirm];
}

@end

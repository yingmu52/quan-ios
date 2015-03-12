//
//  PopupView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupView;

@protocol PopupViewDelegate <NSObject>

- (void)popupViewDidPressCancel:(PopupView *)popupView;
- (void)popupViewDidPressConfirm:(PopupView *)popupView;

@end
@interface PopupView : UIView
@property (weak, nonatomic) IBOutlet UIView *popUpBackground;
@property (weak, nonatomic) IBOutlet UIImageView *headBannerImageView;
@property (weak, nonatomic) IBOutlet UILabel *headBannerLabel;
@property (weak, nonatomic) IBOutlet UILabel *HeadDeleteLabel;
@property (weak, nonatomic) IBOutlet UIView *mainBackground;

@property (nonatomic,weak) id <PopupViewDelegate> delegate;

+ (instancetype)instantiateFromNib:(CGRect)frame;
+ (instancetype)showPopupFinishinFrame:(CGRect)frame;
+ (instancetype)showPopupFailinFrame:(CGRect)frame;
+ (instancetype)showPopupDeleteinFrame:(CGRect)frame;
@end

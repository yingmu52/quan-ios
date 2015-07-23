//
//  PopupView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-10.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
@class PopupView;

@protocol PopupViewDelegate <NSObject>

- (void)popupViewDidPressCancel:(PopupView *)popupView;
- (void)popupViewDidPressConfirm:(PopupView *)popupView;

@end

@interface PopupView : UIView


typedef enum {
    PopupViewStateDelete = 0,
    PopupViewStateGiveUp,
    PopupViewStateFinish
}PopupViewState;


@property (weak, nonatomic) IBOutlet UIView *popUpBackground;
@property (weak, nonatomic) IBOutlet UIImageView *headBannerImageView;
@property (weak, nonatomic) IBOutlet UILabel *headBannerLabel;
@property (weak, nonatomic) IBOutlet UILabel *HeadDeleteLabel;
@property (weak, nonatomic) IBOutlet UIView *mainBackground;
@property (nonatomic,readonly) PopupViewState state;
@property (nonatomic,strong) Plan *plan;
@property (nonatomic,strong) Feed *feed;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


@property (nonatomic,weak) id <PopupViewDelegate> delegate;

+ (instancetype)instantiateFromNib:(CGRect)frame;
+ (instancetype)showPopupFinishinFrame:(CGRect)frame;
+ (instancetype)showPopupFailinFrame:(CGRect)frame;
+ (instancetype)showPopupDeleteinFrame:(CGRect)frame;
+ (instancetype)showPopupDeleteinFrame:(CGRect)frame withTitle:(NSString *)title;
@end

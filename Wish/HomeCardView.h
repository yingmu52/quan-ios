//
//  HomeCardView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeCardView;
@protocol HomeCardViewDelegate <NSObject>

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button;

@end

@interface HomeCardView : UIView
@property (nonatomic,strong) UIImage *dataImage;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subtitle;
@property (nonatomic,strong) NSString *countDowns;
@property (nonatomic,weak) id <HomeCardViewDelegate> delegate;

+ (instancetype)instantiateFromNibWithSuperView:(UIView *)superView;

@end

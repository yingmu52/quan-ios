//
//  HomeCardView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
@class HomeCardView;
@protocol HomeCardViewDelegate <NSObject>

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button;
- (void)didTapOnHomeCardView:(HomeCardView *)cardView;
@end

@interface HomeCardView : UIView

@property (nonatomic,strong) Plan *plan;

@property (nonatomic,weak) id <HomeCardViewDelegate> delegate;

+ (instancetype)instantiateFromNibWithSuperView:(UIView *)superView;

@end

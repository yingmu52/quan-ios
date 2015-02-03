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

@interface HomeCardView : UICollectionViewCell
@property (nonatomic,strong) Plan *plan;
@property (nonatomic,weak) id <HomeCardViewDelegate> delegate;


- (IBAction)dismissMoreView:(id)sender;

- (IBAction)showMoreView:(id)sender;

@end

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

- (void)didTapOnHomeCardView:(HomeCardView *)cardView;
- (void)didLongPressedOn:(HomeCardView *)cardView gesture:(UILongPressGestureRecognizer *)longPress;
@end

@interface HomeCardView : UICollectionViewCell
@property (nonatomic,strong) Plan *plan;
@property (nonatomic,weak) id <HomeCardViewDelegate> delegate;

@end

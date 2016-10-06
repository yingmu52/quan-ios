//
//  HomeCardView.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+CoreDataClass.h"

@class HomeCardView;

@protocol HomeCardViewDelegate <NSObject>
@optional
- (void)didPressCameraOnCard:(HomeCardView *)cardView;
@end

@interface HomeCardView : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic,weak) id <HomeCardViewDelegate>delegate;
@end

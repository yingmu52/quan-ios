//
//  AchieveCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TriangleCutoutView.h"
#define ACHIEVECELLID @"AchievementCell"
@interface AchieveCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet TriangleCutoutView *cardBackgroundView;

@end

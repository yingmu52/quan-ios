//
//  AchieveCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "AchieveCell.h"

@implementation AchieveCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setCardBackgroundView:(TriangleCutoutView *)cardBackgroundView{
    _cardBackgroundView = cardBackgroundView;
    _cardBackgroundView.referenceBadgeView = self.badgeImageView;
}
@end

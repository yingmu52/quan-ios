//
//  DiscoveryCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
//#define NORMALCELLID @"DiscoveryCell"
#define NORMALCELLID @"DiscoveryCellTmp"

@interface DiscoveryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *discoveryFollowerCountLabel;
@property (weak, nonatomic) IBOutlet UIView *discoveryBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *discoveryImageView;
@property (weak, nonatomic) IBOutlet UILabel *discoveryTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *discoveryByUserLabel;

@end

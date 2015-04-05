//
//  DiscoveryBannerCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BANNERID @"DiscoveryBannerCell"

@interface DiscoveryBannerCell : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *bannerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *byUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

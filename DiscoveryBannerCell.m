//
//  DiscoveryBannerCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryBannerCell.h"
#import "UIImage+ImageEffects.h"
@implementation DiscoveryBannerCell

- (void)setBackgroundImageView:(UIImageView *)backgroundImageView{
    _backgroundImageView = backgroundImageView;
    if (_backgroundImageView.image) {
        _backgroundImageView.image = [_backgroundImageView.image applyDarkEffect];
    }
}
@end

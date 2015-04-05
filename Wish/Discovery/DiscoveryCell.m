//
//  DiscoveryCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryCell.h"
#import "SystemUtil.h"

@implementation DiscoveryCell


- (void)setDiscoveryBackgroundView:(UIView *)discoveryBackgroundView{
    _discoveryBackgroundView = discoveryBackgroundView;
    [SystemUtil setupShawdowForView:_discoveryBackgroundView];
    
}
@end

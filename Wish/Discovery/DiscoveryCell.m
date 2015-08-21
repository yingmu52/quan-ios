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


-(void)awakeFromNib{
    [super awakeFromNib];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowOpacity = 0.15f;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

@end

//
//  MSCollectionCell.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/28/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSCollectionCell.h"

@implementation MSCollectionCell



- (void)setMs_shouldHaveBorder:(BOOL)ms_shouldHaveBorder{
    _ms_shouldHaveBorder = ms_shouldHaveBorder;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowOpacity = 0.15f;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.ms_imageView1.image = nil;
    self.ms_imageView2.image = nil;
    self.ms_imageView3.image = nil;
}


@end

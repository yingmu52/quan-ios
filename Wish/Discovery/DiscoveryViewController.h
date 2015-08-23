//
//  DiscoveryViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-17.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoveryCell.h"

@interface DiscoveryViewController : UICollectionViewController
@property (nonatomic,strong) UIButton *addButton;
@property (nonatomic) CGFloat lastContentOffSet;

- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath; //abstract
@end

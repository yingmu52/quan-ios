//
//  HomeCardViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCardView.h"
#import "MSSuperViewController.h"
@interface HomeCardViewController : MSSuperViewController
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
- (void)configureCollectionViewCell:(HomeCardView *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

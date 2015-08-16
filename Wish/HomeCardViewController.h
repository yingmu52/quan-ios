//
//  HomeCardViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCardView.h"

@interface HomeCardViewController : UIViewController 
@property (nonatomic,weak) IBOutlet UILabel *versionLabel;
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

- (void)configureCollectionViewCell:(HomeCardView *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

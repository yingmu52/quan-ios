//
//  HomeCardViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCardViewController : UIViewController 

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

- (void)configureCollectionViewCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

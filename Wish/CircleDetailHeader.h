//
//  CircleDetailHeader.h
//  Stories
//
//  Created by Xinyi Zhuang on 02/12/2016.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Circle+CoreDataClass.h"


@interface CircleDetailHeader : UIView
@property (nonatomic,weak) IBOutlet UIImageView *circleImageView;
@property (nonatomic,weak) IBOutlet UILabel *circleTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *followCountLabel;
@property (nonatomic,weak) IBOutlet UIButton *followButton;
@property (nonatomic,weak) IBOutlet UITextView *circleDescriptionTextView;
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;


- (void)setupHeaderView:(Circle *)circle;
- (void)updateFollowButton:(Circle *)circle;
@end

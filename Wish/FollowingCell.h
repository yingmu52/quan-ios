//
//  FollowingCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
@interface FollowingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *headTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *headUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *wishDetailCollectionView;

@property (nonatomic,strong) Plan *plan
@end

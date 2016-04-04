//
//  FollowingCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
#import "AMBCircularButton.h"
@class FollowingCell;

@protocol FollowingCellDelegate <NSObject>
- (void)didPressMoreButtonForCell:(FollowingCell *)cell;
//- (void)didTapOnProfilePicture:(FollowingCell *)cell;
- (void)didPressCollectionCellAtIndex:(NSIndexPath *)indexPath forCell:(FollowingCell *)cell;
@end
@interface FollowingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *headTitleLabel;
@property (weak, nonatomic) IBOutlet AMBCircularButton *headProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *headUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *feedsArray;

@property (nonatomic,weak) id <FollowingCellDelegate> delegate;
@end

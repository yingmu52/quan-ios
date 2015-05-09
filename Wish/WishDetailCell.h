//
//  WishDetailCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@class WishDetailCell;

@protocol WishDetailCellDelegate <NSObject>

@optional
- (void)didPressedLikeOnCell:(WishDetailCell *)cell;
- (void)didPressedMoreOnCell:(WishDetailCell *)cell;
- (void)didPressedCommentOnCell:(WishDetailCell *)cell;

@end

@interface WishDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
//@property (nonatomic) BOOL isWidgetVisible;
@property (nonatomic,strong) Feed *feed;



@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;



@property (weak,nonatomic) id <WishDetailCellDelegate> delegate;


- (IBAction)like:(UIButton *)sender;
//-(void)showLikeAndComment;
//- (void)dismissLikeAndComment;
//- (void)moveWidget:(BOOL)toVisible;
@end

//
//  WishDetailCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed+CoreDataClass.h"

@class WishDetailCell;

@protocol WishDetailCellDelegate <NSObject>

@optional
- (void)didPressedLikeOnCell:(WishDetailCell *)cell;
- (void)didPressedMoreOnCell:(WishDetailCell *)cell;
@end

@interface WishDetailCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *imageView1;
@property (weak, nonatomic) IBOutlet UIButton *imageView2;
@property (weak, nonatomic) IBOutlet UIButton *imageView3;
@property (weak, nonatomic) IBOutlet UIButton *imageView4;
@property (weak, nonatomic) IBOutlet UIButton *imageView5;
@property (weak, nonatomic) IBOutlet UIButton *imageView6;
@property (weak, nonatomic) IBOutlet UIButton *imageView7;
@property (weak, nonatomic) IBOutlet UIButton *imageView8;
@property (weak, nonatomic) IBOutlet UIButton *imageView9;
@property (weak, nonatomic) IBOutlet UIButton *imageView10;
@property (weak, nonatomic) IBOutlet UIButton *imageView11;
@property (weak, nonatomic) IBOutlet UIButton *imageView12;



@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;


@property (weak,nonatomic) id <WishDetailCellDelegate> delegate;

- (IBAction)like:(UIButton *)sender;
- (CGFloat)setupForImageCount:(NSArray *)imageIds;
@end

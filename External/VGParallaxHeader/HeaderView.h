//
//  HeaderView.h
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+CoreDataClass.h"
#import "GCPTextView.h"
//#define EMPTY_PLACEHOLDER_OWNER @"+添加描述能让别人更了解这件事儿哦~"
@protocol HeaderViewDelegate <NSObject>
@optional
- (void)didPressedLockButton;
- (void)didPressedCircleButton;
//- (void)didPressedFollow:(UIButton *)sender;
//- (void)didPressedUnFollow:(UIButton *)sender;
@end
@interface HeaderView : UIView
//@property (nonatomic,weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerFeedCountLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerFollowLabel;
@property (nonatomic,weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic,weak) IBOutlet UIButton *circleButton;
@property (nonatomic,weak) IBOutlet UIButton *lockButton;
//@property (nonatomic,weak) IBOutlet UIButton *followButton;
@property (nonatomic,weak) IBOutlet GCPTextView *descriptionTextView;

@property (weak,nonatomic) id <HeaderViewDelegate> delegate;
+ (instancetype)instantiateFromNib:(CGRect)frame;
- (void)updateHeaderWithPlan:(Plan *)plan;
@end

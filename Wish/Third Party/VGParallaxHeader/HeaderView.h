//
//  HeaderView.h
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+PlanCRUD.h"
#import "GCPTextView.h"

@protocol HeaderViewDelegate <NSObject>
@optional
- (void)didPressedFollow:(UIButton *)sender;
- (void)didPressedUnFollow:(UIButton *)sender;
@end
@interface HeaderView : UIView
@property (nonatomic,weak) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerFeedCountLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerFollowLabel;
@property (nonatomic,weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic,weak) IBOutlet UIButton *followButton;
@property (nonatomic,weak) IBOutlet GCPTextView *descriptionTextView;
@property (nonatomic,strong) Plan *plan;
@property (weak,nonatomic) id <HeaderViewDelegate> delegate;
+ (instancetype)instantiateFromNib:(CGRect)frame;

@end

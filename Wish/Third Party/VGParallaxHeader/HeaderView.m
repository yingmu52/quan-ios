//
//  HeaderView.m
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import "HeaderView.h"
#import "SystemUtil.h"
#import "Plan.h"
#import "Owner.h"
#import "User.h"
@interface HeaderView()

@end
@implementation HeaderView

- (void)setPlan:(Plan *)plan
{
    _plan = plan;
    self.headerTitleLabel.text = [plan.planTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.headerFeedCountLabel.text = [NSString stringWithFormat:@"%@条记录",plan.tryTimes];
    self.headerFollowLabel.text = [NSString stringWithFormat:@"%@关注",plan.followCount];
    self.badgeImageView.hidden = (self.plan.planStatus.integerValue != PlanStatusFinished);
    
    if ([plan.owner.ownerId isEqualToString:[User uid]]) { //owner don't get to follow its plan
        [self.followButton removeFromSuperview];
    }else{
        [self showFollowButtonWithTitle:(plan.isFollowed.boolValue ? @"已关注" :@"关注")];
    }
}

- (void)showFollowButtonWithTitle:(NSString *)title{
    [UIView setAnimationsEnabled:NO]; // avoid set title animation for behave correctly
    [self.followButton setTitle:title forState:UIControlStateNormal];
    self.followButton.hidden = NO;
    [self.followButton layoutIfNeeded];
    [UIView setAnimationsEnabled:YES];
}
//- (void)updateCountDownLabel:(Plan *)plan{

//    NSInteger totalDays = [SystemUtil daysBetween:plan.createDate and:plan.finishDate];
//    NSInteger pastDays = [SystemUtil daysBetween:plan.createDate and:[NSDate date]];
//    NSInteger results = totalDays - pastDays;

//    if ([plan.planStatus isEqualToNumber:@(PlanStatusOnGoing)]) {
//        self.headerCountDownLabel.text = [NSString stringWithFormat:@"%@%@天",results >= 0 ? @"剩余":@"已过期",@(ABS(results))];
//    }else{
//        self.headerCountDownLabel.text = [NSString stringWithFormat:@"%@%@天",results >= 0 ? @"历时":@"过期",@(ABS(results))];
//    }
//}

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    HeaderView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    return view;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}


- (IBAction)followButtonPressed:(UIButton *)sender{
    if ([sender.titleLabel.text isEqual:@"关注"]) {
        //send follow request
        [self.delegate didPressedFollow:sender];
    }else if ([sender.titleLabel.text isEqual:@"已关注"]){
        //send unfollow request
        [self.delegate didPressedUnFollow:sender];
    }
    sender.hidden = YES;
}

@end





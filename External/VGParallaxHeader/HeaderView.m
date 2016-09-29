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
#import "Theme.h"
#import "Circle.h"
@import QuartzCore;
@interface HeaderView()

@end
@implementation HeaderView

- (void)updateHeaderWithPlan:(Plan *)plan{
    self.headerTitleLabel.text = plan.planTitle;
    self.headerFeedCountLabel.text = [NSString stringWithFormat:@"%@条记录",plan.tryTimes];
    self.headerFollowLabel.text = [NSString stringWithFormat:@"%@人阅读",plan.readCount];
    self.badgeImageView.hidden = (plan.planStatus.integerValue != PlanStatusFinished);
    
    UIImage *lockImg =
    plan.isPrivate.boolValue ? [Theme wishDetailcircleLockButtonLocked] : [Theme wishDetailcircleLockButtonUnLocked];
    [self.lockButton setImage:lockImg forState:UIControlStateNormal];
    
    if (plan.circle.circleId.length > 0) {
        [self.circleButton setTitle:[NSString stringWithFormat:@"所属圈子：%@",plan.circle.circleName]
                           forState:UIControlStateNormal];
    }else{
        [self.circleButton setTitle:@"** 该事件暂时没有所属圈子 **"
                           forState:UIControlStateNormal];
    }
//    self.userNameLabel.text = [NSString stringWithFormat:@"by %@",plan.owner.ownerName];
    if ([plan.owner.ownerId isEqualToString:[User uid]]) { //owner don't get to follow its plan
//        [self.followButton removeFromSuperview];
//        [self.descriptionTextView setPlaceholder:EMPTY_PLACEHOLDER_OWNER];
        [self.descriptionTextView setReturnKeyType:UIReturnKeyDone];
    }else{
        //描述为空的时候，隐藏事件描述
        self.descriptionTextView.hidden = !plan.hasDetailText;
//        [self showFollowButtonWithTitle:(plan.isFollowed.boolValue ? @"已关注" :@"关注")];
    }
    self.descriptionTextView.text = plan.detailText;
//    self.followButton.hidden = [plan.owner.ownerId isEqualToString:[User uid]] | [User isVisitor];
}

//- (void)showFollowButtonWithTitle:(NSString *)title{
//    [UIView setAnimationsEnabled:NO]; // avoid set title animation for behave correctly
//    [self.followButton setTitle:title forState:UIControlStateNormal];
//    self.followButton.hidden = NO;
//    [self.followButton layoutIfNeeded];
//    [UIView setAnimationsEnabled:YES];
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
    self.descriptionTextView.userInteractionEnabled = NO;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    self.circleButton.layer.cornerRadius = 17.0f;
    self.lockButton.layer.cornerRadius = 11.0f;
}

//- (IBAction)followButtonPressed:(UIButton *)sender{
//    if ([sender.titleLabel.text isEqual:@"关注"]) {
//        //send follow request
//        [self.delegate didPressedFollow:sender];
//    }else if ([sender.titleLabel.text isEqual:@"已关注"]){
//        //send unfollow request
//        [self.delegate didPressedUnFollow:sender];
//    }
//    sender.hidden = YES;
//}

//- (IBAction)backgroundTapped:(UITapGestureRecognizer *)tap{
//    if (self.descriptionTextView.isFirstResponder) {
//        [self.descriptionTextView resignFirstResponder];
//    }
//    
//}

- (IBAction)lockButtonPressed{
    [self.delegate didPressedLockButton];
}


- (IBAction)circleButtonPressed{
    [self.delegate didPressedCircleButton];
}


@end





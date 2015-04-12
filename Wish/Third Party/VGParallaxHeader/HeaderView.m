//
//  HeaderView.m
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import "HeaderView.h"
#import "SystemUtil.h"
@interface HeaderView()

@end
@implementation HeaderView

- (void)setPlan:(Plan *)plan
{
    _plan = plan;
    if (plan) {
        self.headerTitleLabel.text = [plan.planTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.headerSubTitleLabel.text = [NSString stringWithFormat:@"已留下%@个努力瞬间",plan.tryTimes];
        self.headerFollowLabel.text = [NSString stringWithFormat:@"%@关注",plan.followCount];
        [self updateCountDownLabel:plan];
    }
}

- (void)updateCountDownLabel:(Plan *)plan{

    NSInteger totalDays = [SystemUtil daysBetween:plan.createDate and:plan.finishDate];
    NSInteger pastDays = [SystemUtil daysBetween:plan.createDate and:[NSDate date]];
    NSInteger results = totalDays - pastDays;

    if ([plan.planStatus isEqualToNumber:@(PlanStatusOnGoing)]) {
        self.headerCountDownLabel.text = [NSString stringWithFormat:@"%@%@天",results >= 0 ? @"剩余":@"已过期",@(ABS(results))];
    }else{
        self.headerCountDownLabel.text = [NSString stringWithFormat:@"%@%@天",results >= 0 ? @"历时":@"过期",@(ABS(results))];
    }
}

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    return [views firstObject];
}


- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

@end

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

@property (nonatomic,weak) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerSubTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerCountDownLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerFollowLabel;
@end
@implementation HeaderView


- (void)setPlan:(Plan *)plan
{
    _plan = plan;
    if (plan) {
        [self updateTitle:plan.planTitle];
        [self updateSubtitle:plan.feeds.count]; //plan.tasks count
        
        NSInteger pastDays = [SystemUtil daysBetween:plan.createDate and:[NSDate date]];
        NSInteger totalDays = [SystemUtil daysBetween:plan.createDate and:plan.finishDate];
        [self updateCountDownLabel:pastDays totalDays:totalDays];
        [self updateFollowCount:plan.followCount.integerValue];
    }
}

- (void)updateTitle:(NSString *)string{
    self.headerTitleLabel.text = string;
}
- (void)updateSubtitle:(NSInteger)tryTime{
    self.headerSubTitleLabel.text = [NSString stringWithFormat:@"已留下%ld个努力瞬间",(long)tryTime];
}

- (void)updateCountDownLabel:(NSInteger)pastDays totalDays:(NSInteger)totalDays{
    self.headerCountDownLabel.text = [NSString stringWithFormat:@"%ld/%ld 天",(long)pastDays,(long)totalDays];
}

- (void)updateFollowCount:(NSInteger)count{
    self.headerFollowLabel.text = [NSString stringWithFormat:@"%ld 关注",(long)count];
}
+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    return [views firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self) {
        self.headerTitleLabel.text = @"无标题";
        [self updateSubtitle:0];
        [self updateCountDownLabel:0 totalDays:0];
        [self updateFollowCount:0];
        
    }

}
@end

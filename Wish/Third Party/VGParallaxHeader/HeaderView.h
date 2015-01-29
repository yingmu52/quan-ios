//
//  HeaderView.h
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
@interface HeaderView : UIView

@property (nonatomic,strong) Plan *plan;
+ (instancetype)instantiateFromNib;


- (void)updateTitle:(NSString *)string;
- (void)updateSubtitle:(NSInteger)tryTime;
- (void)updateCountDownLabel:(NSInteger)pastDays totalDays:(NSInteger)totalDays;
- (void)updateFollowCount:(NSInteger)count;

@end

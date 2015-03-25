//
//  HeaderView.h
//  Example
//
//  Created by Marek Serafin on 26/09/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+PlanCRUD.h"
@interface HeaderView : UIView
@property (nonatomic,weak) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerSubTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerCountDownLabel;
@property (nonatomic,weak) IBOutlet UILabel *headerFollowLabel;

@property (nonatomic,strong) Plan *plan;
+ (instancetype)instantiateFromNib;

@end

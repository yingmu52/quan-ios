//
//  PostDetailViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Theme.h"
#import "Plan+PlanCRUD.h"
#import "SystemUtil.h"
#import "WishDetailViewController.h"
#import "FetchCenter.h"

@interface PostDetailViewController : UIViewController
@property (nonatomic,strong) NSString *titleFromPostView;



@property (weak, nonatomic) IBOutlet UILabel *finishDateLabel;
@property (weak, nonatomic) IBOutlet UIView *isPrivateTab;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UILabel *isPrivateLabel;
@property (weak, nonatomic) IBOutlet UIView *dateBackground;

@property (nonatomic,strong) NSDate *selectedDate;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *pickerToolBar;
@property (strong,nonatomic) UIView *bgView;

@property (nonatomic) BOOL isPrivate;
@property (nonatomic,strong) UIButton *nextButton;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) Plan *plan;



- (void)setViewBorder:(UIView *)view;


- (void)doneEditing; 
@end

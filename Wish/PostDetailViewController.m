//
//  PostDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostDetailViewController.h"
#import "Theme.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "SystemUtil.h"
#import "WishDetailViewController.h"
@interface PostDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *finishDateLabel;
@property (nonatomic,strong) NSDate *selectedDate;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *pickerToolBar;
@property (strong,nonatomic) UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *isPrivateTab;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UILabel *isPrivateLabel;
@property (nonatomic) BOOL isPrivate;

@property (nonatomic,strong) Plan *createdPlan;
@end

@implementation PostDetailViewController

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    NSString *dateString = [SystemUtil stringFromDate:selectedDate];
    self.finishDateLabel.text = [NSString stringWithFormat:@"  预计 %@ 完成",dateString];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.finishDateLabel.text = [NSString stringWithFormat:@"  预计 %@ 完成",[SystemUtil stringFromDate:[NSDate date]]];
    self.finishDateLabel.layer.borderColor = [Theme postTabBorderColor].CGColor;
    self.finishDateLabel.layer.borderWidth = 1.0;
    self.datePicker.backgroundColor = [UIColor whiteColor];
}
- (IBAction)finishDateIsTapped:(UITapGestureRecognizer *)sender {
    self.bgView =[[UIView alloc] initWithFrame:self.view.bounds];
    self.bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    CGRect frame = CGRectMake(0, self.bgView.frame.size.height - 216.0, self.bgView.frame.size.width,216.0);
    self.datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:3600]; // minimum date is from tomorrow on

    [self.datePicker addTarget:self action:@selector(pickerChanged:)
              forControlEvents:UIControlEventValueChanged];

    self.pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(.0, self.datePicker.frame.origin.y - 44.0, self.datePicker.frame.size.width, 44.0)];
    self.pickerToolBar.backgroundColor = self.datePicker.backgroundColor;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(dismissPickerView:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(dismissPickerView:)];
    self.pickerToolBar.items = @[cancel,flexibleSpace,done];
    
    [self.bgView addSubview:self.datePicker];
    [self.bgView addSubview:self.pickerToolBar];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.bgView];

}

- (void)pickerChanged:(UIDatePicker *)picker{
    self.selectedDate = picker.date;
}

- (void)dismissPickerView:(UIBarButtonItem *)item
{
    if ([item.title isEqualToString:@"取消"]) {
        NSString *dateString = [SystemUtil stringFromDate:[NSDate date]];
        self.finishDateLabel.text = [NSString stringWithFormat:@"  预计 %@ 完成",dateString];
    }
    [self.bgView removeFromSuperview];
    [self.pickerToolBar removeFromSuperview];
    [self.datePicker removeFromSuperview];
}
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    UIButton *nextButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                           target:self
                                         selector:@selector(createPlan)
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
}

- (void)setIsPrivate:(BOOL)isPrivate
{
    _isPrivate = isPrivate;
    if (isPrivate){
        self.lockImageView.image = [Theme privacyIconSelected];
        self.isPrivateLabel.text = @"私密愿望";
        self.isPrivateTab.backgroundColor = [Theme privacyBackgroundSelected];
    }else{
        self.lockImageView.image = [Theme privacyIconDefault];
        self.isPrivateLabel.text = @"设为私密愿望";
        self.isPrivateTab.backgroundColor = [Theme privacyBackgroundDefault];
        
    }
    
}
- (IBAction)tapOnPrivacyTab:(UITapGestureRecognizer *)sender {
    self.isPrivate = !self.isPrivate;
}

- (void)createPlan
{
    
    self.createdPlan = [Plan createPlan:self.titleFromPostView
                                date:self.selectedDate
                             privacy:self.isPrivate
                               image:nil
                           inContext:[AppDelegate getContext]];
    [self performSegueWithIdentifier:@"doneWirtingAPost" sender:nil];
   
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"doneWirtingAPost"]) {
        WishDetailViewController *wdvc = segue.destinationViewController;
        wdvc.plan = self.createdPlan;
    }
}
@end

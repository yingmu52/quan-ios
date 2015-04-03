//
//  PostDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostDetailViewController.h"
#import "SDWebImageCompat.h"
@interface PostDetailViewController () 
@end
@implementation PostDetailViewController


@synthesize selectedDate = _selectedDate;


- (NSDate *)tomorrow{
    return [NSDate dateWithTimeIntervalSinceNow:3600]; // minimum date is from tomorrow on
}

- (NSDate *)selectedDate
{
    if (!_selectedDate) {
        _selectedDate = [self tomorrow];
    }
    return _selectedDate;
}
- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    NSString *dateString = [SystemUtil stringFromDate:selectedDate];
    self.finishDateLabel.text = [NSString stringWithFormat:@"预计%@完成",dateString];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    
    self.finishDateLabel.text = [NSString stringWithFormat:@"预计%@完成",[SystemUtil stringFromDate:[NSDate date]]];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self setViewBorder:self.dateBackground];
    [self setViewBorder:self.isPrivateTab];

}
- (void)setViewBorder:(UIView *)view{
    view.layer.borderColor = [Theme postTabBorderColor].CGColor;
    view.layer.borderWidth = 1.0;
}
- (IBAction)finishDateIsTapped:(UITapGestureRecognizer *)sender {
    self.bgView =[[UIView alloc] initWithFrame:self.view.bounds];
    self.bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    CGRect frame = CGRectMake(0, self.bgView.frame.size.height - 216.0, self.bgView.frame.size.width,216.0);
    self.datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [self tomorrow];

    [self.datePicker addTarget:self action:@selector(pickerChanged:)
              forControlEvents:UIControlEventValueChanged];

    self.pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(.0, self.datePicker.frame.origin.y - 44.0, self.datePicker.frame.size.width, 44.0)];
    self.pickerToolBar.barTintColor = self.datePicker.backgroundColor;
    self.pickerToolBar.translucent = NO;
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
    
    self.pickerToolBar.items = @[flexibleSpace,cancel,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,flexibleSpace,done,flexibleSpace];
    
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
        self.finishDateLabel.text = [NSString stringWithFormat:@"预计%@完成",dateString];
    }
    [self.bgView removeFromSuperview];
    [self.pickerToolBar removeFromSuperview];
    [self.datePicker removeFromSuperview];
}
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    self.backButton = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    self.nextButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                           target:self
                                         selector:@selector(doneEditing)
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
    
    //set navigation bar title and color
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    self.title = self.titleFromPostView;
    
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

- (void)doneEditing
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.nextButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    self.plan = [Plan createPlan:self.titleFromPostView
                             date:self.selectedDate
                          privacy:self.isPrivate
                            image:nil];
    FetchCenter *fc = [[FetchCenter alloc] init];
    fc.delegate = self;
    [fc uploadToCreatePlan:self.plan];
//    self.backButton.enabled = NO;
   
}

- (void)didFinishUploadingPlan:(Plan *)plan{
    dispatch_main_async_safe(^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
//        self.backButton.enabled = YES;
        [self performSegueWithIdentifier:@"doneWirtingAPost" sender:plan];
    });
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    dispatch_main_async_safe((^{
        //show alerts
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                    message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        
        //remove plan from core data
        if ([managedObject isKindOfClass:[Plan class]]){
            Plan *plan = (Plan *)managedObject;
            [plan deleteSelf];
        }
        
        //update navigation item
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
//        self.backButton.enabled = YES;

    }));

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Plan *)sender
{
    if ([segue.identifier isEqualToString:@"doneWirtingAPost"]) {
        [segue.destinationViewController setPlan:sender];
    }
}
@end

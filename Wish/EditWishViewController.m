//
//  EditWishViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-25.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "EditWishViewController.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "PopupView.h"
#import "SDWebImageCompat.h"
#import "GCPTextView.h"
#import "FetchCenter.h"
@interface EditWishViewController () <PopupViewDelegate,FetchCenterDelegate>
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet GCPTextView *textView;
@property (nonatomic,weak) PopupView *popView;
@property (nonatomic,weak) IBOutlet UILabel *wordCountLabel;
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end
@implementation EditWishViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupTextField];
    [self setupContent];
}

- (void)setupNavigationItem{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backButton = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                     target:self
                                   selector:@selector(doneEditing)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
}


- (void)setupTextField{
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,5,1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
//    [self setViewBorder:self.textField];
}


- (void)setupContent{
    self.textField.placeholder = self.plan.planTitle;
    [self.textView setPlaceholder:@"添加描述能让别人更了解这件事儿哦~"];
    self.wordCountLabel.text = [NSString stringWithFormat:@"%@/75",@(self.plan.planTitle.length)];
    
}

- (void)doneEditing{
    
#warning !!!!
    if (self.textField.hasText && ![self.textField.text isEqualToString:self.plan.planTitle]){
        //update Plan
        [self.fetchCenter updatePlan:self.plan];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}
- (void)didFinishUpdatingPlan:(Plan *)plan{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    //update navigation item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    
    //show alerts
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.managedObjectContext rollback];
    [delegate.managedObjectContext refreshObject:self.plan mergeChanges:NO];
}



- (IBAction)tapOnBackground:(UITapGestureRecognizer *)sender{
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
}

- (IBAction)giveUp:(UIButton *)sender{
    [self showPopViewFor:PlanStatusGiveTheFuckingUp];
}

- (IBAction)finish:(UIButton *)sender{
    [self showPopViewFor:PlanStatusFinished];
}


- (void)showPopViewFor:(PlanStatus)status{
    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (status == PlanStatusFinished) {
        self.popView = [PopupView showPopupFinishinFrame:keyWindow.frame];
    }else if (status == PlanStatusGiveTheFuckingUp){
        self.popView = [PopupView showPopupFailinFrame:keyWindow.frame];
    }
    self.popView.delegate = self;
    [keyWindow addSubview:self.popView];
}


#pragma mark - pop up view delegate


- (void)popupViewDidPressCancel:(PopupView *)popupView{
    [popupView removeFromSuperview];
}

- (void)popupViewDidPressConfirm:(PopupView *)popupView{
    
    if (popupView.state == PopupViewStateFinish){
        [self.plan updatePlanStatus:PlanStatusFinished];

    }else if (popupView.state == PopupViewStateGiveUp){
        [self.plan updatePlanStatus:PlanStatusGiveTheFuckingUp];

    }else {
        NSAssert(false, @"error");
    }
    [popupView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end

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
#import "Plan.h"
#import "AppDelegate.h"
#import "SDWebImageCompat.h"
#import "GCPTextView.h"
#import "FetchCenter.h"
@interface EditWishViewController () <FetchCenterDelegate,UITextViewDelegate>
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet GCPTextView *textView;
@property (nonatomic,weak) IBOutlet UILabel *wordCountLabel;
@property (nonatomic,weak) IBOutlet UISwitch *privacySwitch;
@property (nonatomic,weak) IBOutlet UILabel *privacyLabel;
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
    [self.textField addTarget:self action:@selector(textFieldDidUpdate) forControlEvents:UIControlEventEditingChanged];
}


#define text_privacy_on @"事件状态：公开"
#define text_privacy_off @"事件状态：私密"

- (void)setupContent{
    self.textView.delegate = self;
    self.textField.text = self.plan.planTitle;
    [self.textView setPlaceholder:@"添加描述能让别人更了解这件事儿哦~"];
    self.textView.text = self.plan.detailText;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%@/75",@(self.plan.detailText.length)];
    self.privacyLabel.text = self.plan.isPrivate.boolValue ? text_privacy_off : text_privacy_on;
    [self.privacySwitch setOn:!self.plan.isPrivate.boolValue];
}

- (IBAction)togglePrivacySwitch:(UISwitch *)sender {
    self.privacyLabel.text = sender.isOn ? text_privacy_on : text_privacy_off;
}


- (void)doneEditing{
    
    [self.textField resignFirstResponder];
    [self.textView resignFirstResponder];
    
    if (self.textField.hasText &&
        ![self.textField.text isEqualToString:self.plan.planTitle] |
        ![self.textView.text isEqualToString:self.plan.detailText] |
        self.privacySwitch.isOn == self.plan.isPrivate.boolValue){ //开 = 公开 -> isPrivate = 0; 关 = 私密 -> isPrivate = 1

        //开始跑菊花
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        
        //向后台发送更请求
        BOOL isPrivate = !self.privacySwitch.isOn;
        [self.fetchCenter updatePlan:self.plan.planId
                               title:self.textField.text
                           isPrivate:isPrivate
                         description:self.textView.text
                          completion:^
        {
            //菊花关闭
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];            
            [self.navigationController popViewControllerAnimated:YES];
        }];
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


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)sender{
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
}

- (IBAction)giveUp:(UIButton *)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除后的事件不能恢复哦！" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        //改变状态
                                                        [self.plan deleteSelf];
                                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                                    }];
    
    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)finish:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定归档？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        //改变状态
                                                        
                                                        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                                        [spinner startAnimating];
                                                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

                                                        [self.plan updatePlanStatus:PlanStatusFinished];
                                                        [self.fetchCenter updateStatus:self.plan completion:^{
                                                            [spinner stopAnimating];
                                                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
                                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                                            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
                                                        }];
                                                    }];
    
    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - text view delegate 

- (void)textViewDidChange:(UITextView *)textView{
    NSInteger maxCount = 75;
    if (textView.text.length > maxCount) {
        textView.text = [textView.text substringToIndex:maxCount];
    }
    self.wordCountLabel.text = [NSString stringWithFormat:@"%@/%@",@(textView.text.length),@(maxCount)];
}

#pragma mark - text field delegate 

- (void)textFieldDidUpdate{
    if (self.textField.isFirstResponder){
        //keep maximum 15 characters
        NSInteger maxCount = 15;
        if (self.textField.text.length > maxCount) [self.textField setText:[self.textField.text substringToIndex:maxCount]];
    }
}
@end




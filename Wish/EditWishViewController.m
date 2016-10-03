//
//  EditWishViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-25.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "EditWishViewController.h"
#import "SystemUtil.h"
#import "Plan.h"
#import "AppDelegate.h"
#import "SDWebImageCompat.h"
#import "GCPTextView.h"
@interface EditWishViewController () <UITextViewDelegate>
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet GCPTextView *textView;
@property (nonatomic,weak) IBOutlet UILabel *wordCountLabel;
@property (nonatomic,weak) IBOutlet UIButton *privacyRadioButton;
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UIButton *archiveButton;
@property (nonatomic) BOOL isPrivate; //当前用户选择是否公开事件
@end
@implementation EditWishViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupNavigationItem];
    [self setupTextField];
    [self setupRadioButton];
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

- (void)setupRadioButton{
    self.privacyRadioButton.layer.borderWidth = 1.0;
    self.privacyRadioButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.privacyRadioButton setImage:nil forState:UIControlStateNormal];
    [self.privacyRadioButton setImage:[Theme EditPlanRadioButtonCheckMark] forState:UIControlStateSelected];
    [self.privacyRadioButton setImage:[Theme EditPlanRadioButtonCheckMark] forState:UIControlStateHighlighted];
}


//#define text_privacy_on @"事件状态：公开"
//#define text_privacy_off @"事件状态：私密"

- (void)setupContent{
    
    //事件标题
    self.textField.text = self.plan.mTitle;

    //事件描述
    self.textView.delegate = self;
    self.textView.textContainerInset = UIEdgeInsetsZero; //去掉textview四周的空白
    [self.textView setPlaceholder:@"添加描述能让别人更了解这件事儿哦~"];
    self.textView.text = self.plan.mDescription;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%@/75",@(self.plan.mDescription.length)];
    
    //事件公开与私密
    self.isPrivate = self.plan.isPrivate.boolValue;
    NSLog(@"plan is %@",self.plan.isPrivate.boolValue ? @"private": @"public");
    
    if (self.plan.planStatus.integerValue == PlanStatusFinished) {
        [self.archiveButton setTitle:@"恢复" forState:UIControlStateNormal];
    }
}

- (IBAction)tapOnPrivacyRadioButton:(UIButton *)button{
    self.isPrivate = !self.isPrivate;
}

- (void)setIsPrivate:(BOOL)isPrivate{
    _isPrivate = isPrivate;
    [self.privacyRadioButton setSelected:!isPrivate];
}

- (void)doneEditing{
    
    [self.textField resignFirstResponder];
    [self.textView resignFirstResponder];
    
    if (self.textField.hasText &&
        ![self.textField.text isEqualToString:self.plan.mTitle] |
        ![self.textView.text isEqualToString:self.plan.mDescription] |
        self.isPrivate != self.plan.isPrivate.boolValue){ //开 = 公开 -> isPrivate = 0; 关 = 私密 -> isPrivate = 1

        //开始跑菊花
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        
        //向后台发送更请求
        [self.fetchCenter updatePlan:self.plan.mUID
                               title:self.textField.text
                           isPrivate:self.isPrivate
                         description:self.textView.text
                          completion:^
        {
            //菊花关闭
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)sender{
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
}

- (IBAction)giveUp:(UIButton *)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除后的事件不能恢复哦！" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
    {
        //改变状态
        [self.fetchCenter deletePlanId:self.plan.mUID completion:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    }];
    
    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)finish:(UIButton *)sender{
    
    NSString *title;
    PlanStatus statusToChagne = -1; //-1为不支持的状态
    if (self.plan.planStatus.integerValue == PlanStatusOnGoing) {
        title = @"确定归档？";
        statusToChagne = PlanStatusFinished;
    }
    if (self.plan.planStatus.integerValue == PlanStatusFinished) {
        title = @"确定恢复？";
        statusToChagne = PlanStatusOnGoing;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
    {
        //改变状态
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        [self.fetchCenter updatePlanId:self.plan.mUID
                            planStatus:statusToChagne
                            completion:^
        {
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
            [self.navigationController popToRootViewControllerAnimated:YES];
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




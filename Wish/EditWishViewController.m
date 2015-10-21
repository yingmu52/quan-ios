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
#import "SDWebImageCompat.h"
#import "GCPTextView.h"
#import "FetchCenter.h"
@interface EditWishViewController () <FetchCenterDelegate,UITextViewDelegate>
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet GCPTextView *textView;
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
    [self.textField addTarget:self action:@selector(textFieldDidUpdate) forControlEvents:UIControlEventEditingChanged];
}


- (void)setupContent{
    self.textView.delegate = self;
    self.textField.text = self.plan.planTitle;
    [self.textView setPlaceholder:@"添加描述能让别人更了解这件事儿哦~"];
    self.textView.text = self.plan.detailText;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%@/75",@(self.plan.detailText.length)];
}

- (void)doneEditing{
    
    if (self.textField.hasText && ![self.textField.text isEqualToString:self.plan.planTitle] | ![self.textView.text isEqualToString:self.plan.detailText]){
        //update Plan
        self.plan.planTitle = self.textField.text;
        self.plan.detailText = self.textView.text;
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
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    //update navigation item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.managedObjectContext rollback];
    [delegate.managedObjectContext refreshObject:self.plan mergeChanges:NO];
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
                                                        [self.plan updatePlanStatus:PlanStatusFinished];
                                                        [self.navigationController popToRootViewControllerAnimated:YES];
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




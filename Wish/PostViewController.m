//
//  PostViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostViewController.h"
#import "Theme.h"
#import "PostDetailViewController.h"
#import "KeyWordCell.h"
#import "NHAlignmentFlowLayout.h"
@interface PostViewController ()
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,strong) UIButton *tikButton;
@end

@implementation PostViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.textField.text = nil;
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

- (void)setTextField:(UITextField *)textField{
    _textField = textField;
    _textField.layer.borderColor = [Theme postTabBorderColor].CGColor;
    _textField.layer.borderWidth = 1.0;
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,1)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setupViews
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDisable]
                                           target:self
                                         selector:@selector(goToNextView)
                                            frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.textField addTarget:self action:@selector(textFieldDidUpdate) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)textFieldDidUpdate{
    if (self.textField.isFirstResponder){
        BOOL flag = self.textField.text.length*[self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
        
        //keep maximum 15 characters
        NSInteger maxCount = 15;
        if (self.textField.text.length > maxCount) [self.textField setText:[self.textField.text substringToIndex:maxCount]];
    }
}


- (void)goToNextView
{
    [self performSegueWithIdentifier:@"showWritePostDetail" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWritePostDetail"]) {
        PostDetailViewController *pdvc = segue.destinationViewController;
        pdvc.titleFromPostView = self.textField.text;
    }
}

@end

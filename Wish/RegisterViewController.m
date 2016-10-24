//
//  RegisterViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/23/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *indicationLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield1;
@property (nonatomic,strong) UIButton *tickButton;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
    
}


- (void)setupViews{
    NSDictionary *attr = @{NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    self.usernameTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入用户名" attributes:attr];
    self.passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"登陆密码" attributes:attr];
    self.passwordTextfield1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"再次输入密码" attributes:attr];
    self.indicationLabel.hidden = YES;
    
    [self setUpBackButton:NO];
    self.tickButton = [Theme buttonWithImage:[Theme navTikButtonDefault] target:self selector:@selector(done) frame:CGRectMake(0, 0, 25, 25)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tickButton];

    self.title = @"注册";
}

- (void)done{
    [self.usernameTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    [self.passwordTextfield1 resignFirstResponder];
    
    if (![self.passwordTextfield.text isEqualToString:self.passwordTextfield1.text]) {
        self.indicationLabel.hidden = NO;
        return;
    }else{
        self.indicationLabel.hidden = YES;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tickButton.frame];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        [spinner startAnimating];
        
        //register, show main view when finish
        [self.fetchCenter registerWithUsername:self.usernameTextfield.text
                                      password:self.passwordTextfield.text
                                    completion:^
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tickButton];
            [AppDelegate showMainTabbar];
        }];
    }
    
}

- (void)didFailSendingRequestWithMessage:(NSString *)message{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tickButton];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

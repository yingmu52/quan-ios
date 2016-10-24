//
//  OtherLoginViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/23/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "OtherLoginViewController.h"

@interface OtherLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (nonatomic,strong) UIButton *tickButton;
@end

@implementation OtherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews{
    
    NSDictionary *attr = @{NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    self.usernameTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入用户名" attributes:attr];
    self.passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"登陆密码" attributes:attr];
    
    
    
    [self setUpBackButton:NO];
    //tick button
    self.tickButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                      target:self
                                    selector:@selector(done)
                                       frame:CGRectMake(0, 0, 25, 25)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tickButton];
    
    //navigation title
    self.title = @"登陆";
}

- (void)done{
    //login show main view when finish
    if (!self.usernameTextfield.hasText || !self.passwordTextfield.hasText) {
        return;
    }else{
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tickButton.frame];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        [spinner startAnimating];
        [self.fetchCenter loginWithUsername:self.usernameTextfield.text password:self.passwordTextfield.text completion:^{
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

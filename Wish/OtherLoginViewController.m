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
    UIButton *tickButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                           target:self
                                         selector:@selector(done)
                                            frame:CGRectMake(0, 0, 25, 25)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tickButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //navigation title
    self.title = @"登陆";
}

- (void)done{
    //login show main view when finish
}

@end

//
//  InvitationCodeViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-28.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "InvitationCodeViewController.h"

@interface InvitationCodeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UILabel *indicationLabel;

@end

@implementation InvitationCodeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.codeTextField becomeFirstResponder];
}

- (IBAction)confirmPressed {
    self.indicationLabel.hidden = YES;
    [self.codeTextField resignFirstResponder];
    
    if (self.codeTextField.hasText) {
        [self.fetchCenter joinCircle:self.codeTextField.text completion:^(NSString *circleId) {
            NSLog(@"加入成功，圈子id %@",circleId);
            
            //切换到主页
            [[[UIApplication sharedApplication] keyWindow] setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"]];
        }];
    }
}

- (void)didFailSendingRequest{
    self.indicationLabel.hidden = NO;
}

@end

//
//  PostViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostViewController.h"
#import "Theme.h"
@interface PostViewController () <UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn1;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn2;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn3;
@property (nonatomic,weak) IBOutlet UIButton *sgtBtn4;

@end

@implementation PostViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];

}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    UIButton *nextButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                           target:self
                                         selector:@selector(goToNextView)
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];

}

- (void)goToNextView
{
//    [Plan createPlan:self.textField.text
//                date:[NSDate date]
//             privacy:NO
//               image:self.capturedImage
//           inContext:[AppDelegate getContext]];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

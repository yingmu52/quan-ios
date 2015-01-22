//
//  PostViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-20.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostViewController.h"
#import "Theme.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
@interface PostViewController ()

@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIImageView *imageView;

@end

@implementation PostViewController


- (void)setCapturedImage:(UIImage *)capturedImage
{
    _capturedImage = capturedImage;
    self.imageView.image = capturedImage;
}

- (void)setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
    _imageView.image = self.capturedImage;
}

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
    
    UIButton *doneButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                           target:self
                                         selector:@selector(doneCreatingWish)
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];

}

- (void)doneCreatingWish
{
    [Plan createPlan:self.textField.text
                date:[NSDate date]
             privacy:NO
               image:self.capturedImage
           inContext:[AppDelegate getContext]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

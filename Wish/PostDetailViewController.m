//
//  PostDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostDetailViewController.h"
#import "Theme.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "SystemUtil.h"
@interface PostDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *finishDateLabel;


@property (weak, nonatomic) IBOutlet UIView *isPrivateTab;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UILabel *isPrivateLabel;
@property (nonatomic) BOOL isPrivate;
@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}
- (void)viewDidLayoutSubviews
{
    self.finishDateLabel.text = [NSString stringWithFormat:@" 预计 %@ 完成",[SystemUtil stringFromDate:[NSDate date]]];
    self.finishDateLabel.layer.borderColor = [Theme postTabBorderColor].CGColor;
    self.finishDateLabel.layer.borderWidth = 1.0;
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
                                         selector:@selector(createPlan)
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
}

- (void)setIsPrivate:(BOOL)isPrivate
{
    _isPrivate = isPrivate;
    if (isPrivate){
        self.lockImageView.image = [Theme privacyIconSelected];
        self.isPrivateLabel.text = @"私密愿望";
        self.isPrivateTab.backgroundColor = [Theme privacyBackgroundSelected:self.isPrivateTab];
    }else{
        self.lockImageView.image = [Theme privacyIconDefault];
        self.isPrivateLabel.text = @"设为私密愿望";
        self.isPrivateTab.backgroundColor = [Theme privacyBackgroundDefault];
        
    }
    
}
- (IBAction)tapOnPrivacyTab:(UITapGestureRecognizer *)sender {
    self.isPrivate = !self.isPrivate;
}

- (void)createPlan
{
    [Plan createPlan:self.title
                date:[NSDate date]
             privacy:NO
               image:nil
           inContext:[AppDelegate getContext]];
    [self.navigationController popToRootViewControllerAnimated:YES];
   
}
@end

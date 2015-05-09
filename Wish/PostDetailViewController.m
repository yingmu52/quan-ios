//
//  PostDetailViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostDetailViewController.h"
#import "Theme.h"
#import "SystemUtil.h"
@interface PostDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *cameraBackground;

@end
@implementation PostDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self borderiseCameraBackground];
}

- (void)borderiseCameraBackground{
    self.cameraBackground.layer.borderColor = [SystemUtil colorFromHexString:@"#33C6B4"].CGColor;
    self.cameraBackground.layer.borderWidth = 1.5f;
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backButton = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
//    self.nextButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
//                                           target:self
//                                         selector:@selector(doneEditing)
//                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
    
    //set navigation bar title and color
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    self.title = self.titleFromPostView;
    
}

@end

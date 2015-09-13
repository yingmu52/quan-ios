//
//  ImagePreviewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePreviewController.h"
#import "Theme.h"
@interface ImagePreviewController ()

@end

@implementation ImagePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backButton = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                           target:self.navigationController
                                         selector:@selector(popViewControllerAnimated:)
                                            frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}


@end

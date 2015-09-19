//
//  QBPreViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "QBPreViewController.h"
#import "Theme.h"
#import "NavigationBar.h"
@import Photos;
@interface QBPreViewController ()
@end

@implementation QBPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *checkMarkButton = [Theme buttonWithImage:[Theme checkmarkUnSelected]
                                                target:self
                                              selector:nil
                                                 frame:CGRectMake(0, 0, 25, 25)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:checkMarkButton];
    [self setUpToolbarItems];

}

- (void)setArrayOfPhAssets:(NSArray *)arrayOfPhAssets{
    _arrayOfPhAssets = arrayOfPhAssets;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:_arrayOfPhAssets.firstObject targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        self.previewImages = [@[result] mutableCopy];
        [self.collectionView reloadData];
    }];
}

- (void)setUpToolbarItems
{
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80.0, 35.0)];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    button.backgroundColor = [SystemUtil colorFromHexString:@"#51BFA6"];
    button.layer.cornerRadius = 4.0f;
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.toolbarItems = @[space,finishButton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
}
@end

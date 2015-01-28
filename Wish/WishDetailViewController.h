//
//  WishDetailViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FirstTableViewController.h"
#import "Plan.h"
@interface WishDetailViewController : FirstTableViewController

@property (nonatomic,strong) Plan *plan;
@property (nonatomic,strong) UIImage *capturedImage;
@property (nonatomic,strong) UIButton *cameraButton;

@end

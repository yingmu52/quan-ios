//
//  ProfileViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-22.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Theme.h"
#import "SystemUtil.h"
#import "Owner+CoreDataClass.h"
#import "FetchCenter.h"
#import "UIImageView+ImageCache.h"
@interface ProfileViewController : UITableViewController
@property (nonatomic,weak) IBOutlet UITextField *nickNameTextField;
@property (nonatomic,weak) IBOutlet UILabel *genderLabel;
@property (nonatomic,weak) IBOutlet UITextField *occupationTextField;
@property (nonatomic,weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic,strong) Owner *owner; // for view user profile (info is non-editable) 

- (void)goBack;
- (void)setInfoForOwner;
- (void)dismissKeyboard;
@end

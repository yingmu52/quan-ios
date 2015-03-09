//
//  MenuCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MenuCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet UILabel *menuTitle;
@property (weak, nonatomic) IBOutlet UIView *menuBackground;

@property (weak,nonatomic) IBOutlet UIButton *settingButton;
@property (weak,nonatomic) IBOutlet UIButton *messageButton;

@property (weak,nonatomic) IBOutlet UIButton *backupSettingButton;

- (void)hideMessageButton;
- (void)showMessageButton;

@end

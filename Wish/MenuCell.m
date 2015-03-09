//
//  MenuCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MenuCell.h"
#import "SystemUtil.h"
@implementation MenuCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.menuBackground.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)hideMessageButton{
    self.messageButton.hidden = YES;
    self.settingButton.hidden = YES;
    self.backupSettingButton.hidden = NO;
}
- (void)showMessageButton
{
    self.messageButton.hidden = NO;
    self.settingButton.hidden = NO;
    self.backupSettingButton.hidden = YES;
    
}

@end

//
//  EditWishViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-25.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "EditWishViewController.h"
#import "Theme.h"
#import "SystemUtil.h"
@interface EditWishViewController ()
@property (nonatomic,strong) IBOutlet UITextField *textField;
@end
@implementation EditWishViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupTextField];
    self.textField.text = self.plan.planTitle;
    self.finishDateLabel.text = [NSString stringWithFormat:@"预计%@达成",[SystemUtil stringFromDate:self.plan.finishDate]];
    self.isPrivate = self.plan.isPrivate.boolValue;
    self.title = self.plan.planTitle;
}

- (void)setupTextField{
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,5,1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self setViewBorder:self.textField];
}
@end

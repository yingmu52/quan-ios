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
#import "Plan+PlanCRUD.h"
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
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self setViewBorder:self.textField];
}

- (void)doneEditing{
    NSLog(@"test");
}

- (IBAction)finishDateIsTapped:(UITapGestureRecognizer *)sender{
    [super finishDateIsTapped:sender];
    NSLog(@"test");
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
}

- (void)didFinishUploadingPlan:(Plan *)plan{

}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    
}

//- (void)dismissPickerView:(UIBarButtonItem *)item{
//    [super dismissPickerView:item];
////    if (!self.textField.isFirstResponder) [self.textField becomeFirstResponder];
//}



- (IBAction)tapOnBackground:(UITapGestureRecognizer *)sender{
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
}

- (IBAction)giveUp:(UIButton *)sender{
    [self.plan updatePlanStatus:PlanStatusGiveTheFuckingUp];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)finish:(UIButton *)sender{
    [self.plan updatePlanStatus:PlanStatusFinished];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

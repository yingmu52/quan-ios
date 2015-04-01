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
#import "AppDelegate.h"
#import "PopupView.h"
#import "SDWebImageCompat.h"

@interface EditWishViewController () <PopupViewDelegate>
@property (nonatomic,weak) IBOutlet UITextField *textField;
@property (nonatomic,weak) PopupView *popView;
@end
@implementation EditWishViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupTextField];
    self.textField.text = self.plan.planTitle;
    self.finishDateLabel.text = [NSString stringWithFormat:@"预计%@达成",[SystemUtil stringFromDate:self.plan.finishDate]];
    self.isPrivate = self.plan.isPrivate.boolValue;
    self.title = @"编辑愿望";
}

- (void)setupTextField{
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self setViewBorder:self.textField];
}

- (void)doneEditing{
    NSLog(@"test");
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.nextButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.backButton.enabled = NO;
    
    
    [self.plan updatePlan:self.textField.text finishDate:self.selectedDate isPrivated:self.isPrivate];
    
    //set updaing request
    FetchCenter *fc = [[FetchCenter alloc] init];
    fc.delegate = self;
    [fc updatePlan:self.plan];
}


- (IBAction)finishDateIsTapped:(UITapGestureRecognizer *)sender{
    [super finishDateIsTapped:sender];
    NSLog(@"test");
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
}


- (void)didFinishUpdatingPlan:(Plan *)plan{
    dispatch_main_async_safe(^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
        self.backButton.enabled = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
    });
}
- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    dispatch_main_async_safe((^{
        //update navigation item
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
        self.backButton.enabled = YES;
        
        //show alerts
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                    message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.managedObjectContext rollback];
        [delegate.managedObjectContext refreshObject:self.plan mergeChanges:NO];
    }))
}


//- (void)dismissPickerView:(UIBarButtonItem *)item{
//    [super dismissPickerView:item];
////    if (!self.textField.isFirstResponder) [self.textField becomeFirstResponder];
//}



- (IBAction)tapOnBackground:(UITapGestureRecognizer *)sender{
    if (self.textField.isFirstResponder) [self.textField resignFirstResponder];
}

- (IBAction)giveUp:(UIButton *)sender{
    [self showPopViewFor:PlanStatusGiveTheFuckingUp];
}

- (IBAction)finish:(UIButton *)sender{
    [self showPopViewFor:PlanStatusFinished];
}


- (void)showPopViewFor:(PlanStatus)status{
    UIView *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (status == PlanStatusFinished) {
        self.popView = [PopupView showPopupFinishinFrame:keyWindow.frame];
    }else if (status == PlanStatusGiveTheFuckingUp){
        self.popView = [PopupView showPopupFailinFrame:keyWindow.frame];
    }
    self.popView.delegate = self;
    [keyWindow addSubview:self.popView];
}


#pragma mark - pop up view delegate


- (void)popupViewDidPressCancel:(PopupView *)popupView{
    [popupView removeFromSuperview];
}

- (void)popupViewDidPressConfirm:(PopupView *)popupView{
    
    if (popupView.state == PopupViewStateFinish){
        [self.plan updatePlanStatus:PlanStatusFinished];

    }else if (popupView.state == PopupViewStateGiveUp){
        [self.plan updatePlanStatus:PlanStatusGiveTheFuckingUp];

    }else {
        NSAssert(false, @"error");
    }
    [popupView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}







@end

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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
        self.backButton.enabled = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
    });
    
}
- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    dispatch_async(dispatch_get_main_queue(), ^{
        
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
    });

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

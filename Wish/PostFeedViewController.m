//
//  PostFeedViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PostFeedViewController.h"
#import "Theme.h"
#import "KeyboardAcessoryView.h"
#import "SystemUtil.h"
#import "FetchCenter.h"
#import "GCPTextView.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "WishDetailVCOwner.h"
@interface PostFeedViewController () <UITextFieldDelegate,FetchCenterDelegate,GCPTextViewDelegate>
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,weak) IBOutlet UIImageView *previewIcon;
//@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet GCPTextView *textView;


@property (nonatomic,strong) Feed *feed;
@end

@implementation PostFeedViewController

- (Feed *)feed{
    if (!_feed){
        _feed = [Feed createFeedWithImage:self.imageForFeed inPlan:self.plan];
        _feed.feedTitle = self.textView.text;
    }
    return _feed;
}
- (NSString *)titleForFeed{
    return self.textView.text;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupViews];
}

#define placeHolder @"说点什么吧"

- (void)setTextView:(GCPTextView *)textView{
    _textView = textView;
    _textView.delegate = self;
    [_textView setPlaceholder:placeHolder];
    _textView.textContainerInset = UIEdgeInsetsZero;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)setupViews
{
    CGRect frame = CGRectMake(0, 0, 25, 25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(goBack)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDisable]
                                     target:self
                                   selector:@selector(createFeed)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
//    [self.textField addTarget:self action:@selector(textFieldDidUpdate) forControlEvents:UIControlEventEditingChanged];
    
    //left margin
//    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,1)];
//    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
//    self.textField.inputAccessoryView = [KeyboardAcessoryView instantiateFromNib:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 88 / 1136)];

    self.previewIcon.image = self.imageForFeed;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#2A2A2A"]};
    self.title = self.plan.planTitle;
}
- (void)createFeed{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    FetchCenter *fc = [FetchCenter new];
    fc.delegate = self;
    [fc uploadToCreateFeed:self.feed];
}


- (void)goBack{
    [[AppDelegate getContext] deleteObject:self.feed];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - text view delegate


- (void)textViewDidChange:(UITextView *)textView{
    if (self.textView.isFirstResponder){
        BOOL flag = self.textView.text.length*[self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger noc = textView.text.length + (text.length - range.length);
//    NSLog(@"%d",noc);
    return  noc <= 140;
}

- (void)backspaceDidOccurInEmptyField{
    //this method prevents crash when user keep hitting back space
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showWishDetailOnPlanCreation"]){
        [segue.destinationViewController setPlan:sender]; //sender is plan
    }
}
#pragma mark - fetch center delegate 


- (void)didFinishUploadingFeed:(Feed *)feed
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    
    if (!self.seugeFromPlanCreation) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self performSegueWithIdentifier:@"showWishDetailOnPlanCreation" sender:self.plan];

    }
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)didFailUploadingImageWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}


- (void)handleFailure:(NSDictionary *)info{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}
@end

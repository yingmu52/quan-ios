//
//  FeedbackViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Theme.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
@interface FeedbackViewController () <FetchCenterDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic,strong) UIButton *tikButton;
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
}

- (void)setupNavigationItem{
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                     target:self
                                   selector:@selector(sendFeedBack)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];

}

- (void)sendFeedBack{
    if (self.textField.hasText || self.textView.hasText) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        
        FetchCenter *fetchCenter = [[FetchCenter alloc] init];
        fetchCenter.delegate = self;
        [fetchCenter sendFeedback:self.textField.text content:self.textView.text];
    }
}


- (void)didFinishSendingFeedBack{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

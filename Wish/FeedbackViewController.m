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
#import "FeedbackkAccessoryView.h"
#import "GCPTextView.h"
#import "UIViewController+ECSlidingViewController.h"
@interface FeedbackViewController () <FetchCenterDelegate,UITextViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet GCPTextView *textView;
@property (nonatomic,strong) UIButton *tikButton;
@property (nonatomic,strong) FeedbackkAccessoryView *feedbackAccessoryView;
@end

@implementation FeedbackViewController


- (void)setTextView:(GCPTextView *)textView{
    self.automaticallyAdjustsScrollViewInsets = NO; // this line of code fixed the display issue of text view where feed back view is shown modally directly from the menu.
    _textView = textView;
    _textView.text = nil;
    [_textView setPlaceholder:@" 感谢您对我们App的建议~么么哒"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItem];
    self.title = @"反馈";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
    
}
- (void)setupNavigationItem{
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self
                                      selector:@selector(dismissModalViewControllerAnimated:)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                     target:self
                                   selector:@selector(sendFeedBack)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    self.textView.inputAccessoryView = self.feedbackAccessoryView;

}


- (FeedbackkAccessoryView *)feedbackAccessoryView{
    if (!_feedbackAccessoryView){
        CGSize size = self.view.bounds.size;
        CGFloat height = size.height * 88.0f/ 1136;
        _feedbackAccessoryView = [FeedbackkAccessoryView instantiateFromNib:CGRectMake(0, 0, size.width,height)];
    }
    return _feedbackAccessoryView;
}

- (void)sendFeedBack{
    if (self.textView.hasText) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.tikButton.frame];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        
        FetchCenter *fetchCenter = [[FetchCenter alloc] init];
        fetchCenter.delegate = self;
        [fetchCenter sendFeedback:self.textView.text
                          content:((FeedbackkAccessoryView *)self.textView.inputAccessoryView).textField.text];
    }
}

- (void)dismissController{
    //if self is the root of a navigation controller, this is being modally presented
    if (self.navigationController.viewControllers.firstObject == self) { //self is the root view controller
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}
- (void)didFinishSendingFeedBack{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    [[[UIAlertView alloc] initWithTitle:@"反馈成功" message:nil delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil] show];
}


- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"返回"]) {
        [self.view endEditing:YES];
        [self dismissController];
    }
}

#pragma mark text view delegate 
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textView.isFirstResponder){
        BOOL flag = self.textView.text.length*[self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
        self.navigationItem.rightBarButtonItem.enabled = flag;
        UIImage *bg = flag ? [Theme navTikButtonDefault] : [Theme navTikButtonDisable];
        [self.tikButton setImage:bg forState:UIControlStateNormal];
    
        //limit word count
        NSUInteger maxCount = 500;
        if ([textView isFirstResponder] && textView.text.length > maxCount){
            textView.text = [textView.text substringToIndex:maxCount];
        }

    }
    
}

@end








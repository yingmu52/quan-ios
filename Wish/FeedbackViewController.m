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
@interface FeedbackViewController () <FetchCenterDelegate,GCPTextViewDelegate>
@property (weak, nonatomic) IBOutlet GCPTextView *textView;
@property (nonatomic,strong) UIButton *tikButton;
@end

@implementation FeedbackViewController


- (void)setTextView:(GCPTextView *)textView{
    _textView = textView;
    _textView.delegate = self;
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
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.tikButton = [Theme buttonWithImage:[Theme navTikButtonDefault]
                                     target:self
                                   selector:@selector(sendFeedBack)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    
    self.textView.inputAccessoryView = [FeedbackkAccessoryView instantiateFromNib:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 88.0f/ 1136)];

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


- (void)didFinishSendingFeedBack{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.tikButton];
}

#pragma mark text view delegate 
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
    return  noc <= 500;
}

- (void)backspaceDidOccurInEmptyField{
    //this method prevents crash when user keep hitting back space
}
@end








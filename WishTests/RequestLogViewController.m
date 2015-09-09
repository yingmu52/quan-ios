//
//  RequestLogViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-07-01.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "RequestLogViewController.h"
#import "Theme.h"
#import "FetchCenter.h"
@import MessageUI;
@interface RequestLogViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic,weak) IBOutlet UITextView *textView;
@end

@implementation RequestLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupContent];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                     target:self.navigationController
                                   selector:@selector(popViewControllerAnimated:)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self action:@selector(sendLogs)];
    self.title = @"请求日志";
}

- (void)setupContent{
    NSString *content = [NSString stringWithContentsOfFile:[FetchCenter requestLogFilePath]
                                                  encoding:NSUTF8StringEncoding error:nil];
    if (![content isEqualToString:self.textView.text]){
        self.textView.text = content;
        [self scrollTextViewToBottom:self.textView];
    }
}


-(void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
}


#pragma mark - email 

-(void)sendLogs
{
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    [mail setSubject:@"亮瞎双眼的请求日志"];
    [mail addAttachmentData:[NSData dataWithContentsOfFile:[FetchCenter requestLogFilePath]]
                   mimeType:@"text/plain"
                   fileName:@"httpRequestLog.txt"]; // see FetchCenter requestLogFilePath method
    
    [mail setToRecipients:@[@"yingmu52@msn.com",@"185740718@qq.com"]];
    mail.mailComposeDelegate = self;
    if ([MFMailComposeViewController canSendMail]) {
        mail.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:mail animated:YES completion:nil];
    }
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    if (result == MFMailComposeResultCancelled) {
    }else if (result == MFMailComposeResultFailed){
        
    }else if (result == MFMailComposeResultSaved){
        
    }else if (result == MFMailComposeResultSent){
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

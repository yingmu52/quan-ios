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
@interface RequestLogViewController ()
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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(setupContent)];
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

@end

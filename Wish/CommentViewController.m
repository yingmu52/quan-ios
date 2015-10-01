//
//  CommentViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-28.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "CommentViewController.h"
#import "NZCircularImageView.h"
#import "SZTextView.h"
@interface CommentViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NZCircularImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet SZTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBackgroundHeight;
@end

@implementation CommentViewController


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //跟踪键盘高度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //呼起键盘
    [self.textView becomeFirstResponder];
    
    //设置输入框
    self.textView.delegate = self;
    self.textView.placeholder = @"说点什么吧";
    
    //设置输入框UI
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //设置行数限制
    NSUInteger maxNumberOfLines = 4;
    
    //高数当前行数约值
    NSUInteger numLines = textView.contentSize.height/textView.font.lineHeight;
    
    if (numLines < maxNumberOfLines){
        CGFloat computedHeightDifference = textView.contentSize.height - (textView.frame.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom);
        
        //换行后扩展边框
        if (computedHeightDifference) {
            [UIView animateWithDuration:0.5 animations:^{
                self.textViewBackgroundHeight.constant = textView.contentSize.height + textView.textContainerInset.top + textView.textContainerInset.bottom;
                [self.view layoutIfNeeded];
            }];
        }
    }else{
        //滚到输入框最底部
        CGPoint bottomOffset = CGPointMake(0, textView.contentSize.height - textView.frame.size.height);
        [textView setContentOffset:bottomOffset animated:NO];
    }
    
}

#pragma mark - Text View Delegate

#pragma mark - keyboard interaction notification

- (void)keyboardDidHide:(NSNotification *)notification{
    [self updateViewForNewHeight:0];
}

- (void)keyboardDidChange:(NSNotification *)notification{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateViewForNewHeight:CGRectGetHeight(keyboardFrame)];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateViewForNewHeight:CGRectGetHeight(keyboardFrame)];
    
}
- (void)updateViewForNewHeight:(CGFloat)height{
    self.keyboardHeight.constant = height;
    [self.view layoutIfNeeded];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.textView resignFirstResponder];
}

@end

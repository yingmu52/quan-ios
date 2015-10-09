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
#import "UIImageView+ImageCache.h"
#import "SYEmojiPopover.h"
@interface CommentViewController () <UITextViewDelegate,SYEmojiPopoverDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBackgroundHeight;
@property (weak, nonatomic) IBOutlet UIView *userBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NZCircularImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet SZTextView *textView;
@property (nonatomic,strong) SYEmojiPopover *emojiView;
@end

@implementation CommentViewController


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    [self.textView resignFirstResponder];
    [self dismissView];
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
    self.textView.placeholder = self.comment ? [NSString stringWithFormat:@"回复%@：",self.comment.owner.ownerName] : @"说点什么吧...";
    
    //设置输入框UI
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.userBackgroundView.hidden = !self.comment;
    if (self.comment) {
        self.userNameLabel.text = self.comment.owner.ownerName;
        [self.userProfileImageView showImageWithImageUrl:[self.fetchCenter urlWithImageID:self.comment.owner.headUrl size:FetchCenterImageSize100]];
        self.commentContentLabel.text = self.comment.content;
        self.timeLabel.text = [SystemUtil timeStringFromDate:self.comment.createTime];
    }
    
    [self.textView addObserver:self
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    SZTextView *textView = object;

    //设置行数限制，有回复对象时限3行，无回复对象时限6行
    NSUInteger maxNumberOfLines = self.comment ? 6 : 8;
    NSUInteger numLines = fabs((textView.contentSize.height -
                                textView.textContainerInset.top -
                                textView.textContainerInset.bottom) /
                               textView.font.lineHeight);
    if (numLines < maxNumberOfLines){
        //当输入框中的文字没到行限时，动态改变高度
        CGFloat topCorrect = textView.bounds.size.height - textView.contentSize.height;
        [UIView animateWithDuration:0.1 animations:^{
            self.textViewBackgroundHeight.constant -= topCorrect;
            [self.view layoutIfNeeded];
        }];
    }else{
        //滚到输入框最底部
        CGPoint bottomOffset = CGPointMake(0, textView.contentSize.height - textView.frame.size.height);
        [textView setContentOffset:bottomOffset animated:NO];
    }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView
{
//
//    //高数当前行数约值
//    NSUInteger numLines = fabs((textView.contentSize.height -
//                                textView.textContainerInset.top -
//                                textView.textContainerInset.bottom) /
//                               textView.font.lineHeight);
//    
//    if (numLines < maxNumberOfLines){
//        CGFloat computedHeightDifference =
//        textView.contentSize.height +
//        textView.textContainerInset.top +
//        textView.textContainerInset.bottom -
//        textView.frame.size.height;
//        
//        //换行后扩展边框
//        if (computedHeightDifference) {
//        }
//    }else{
//    }
    
}

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
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
    [self.textView resignFirstResponder];
}

#pragma mark - 与后台调联
- (IBAction)sendComment:(id)sender{
    if (self.comment) { //有回复的对象
        [self.fetchCenter replyAtFeed:self.comment.feed
                              content:self.textView.text
                              toOwner:self.comment.owner];
    }else{
        [self.fetchCenter commentOnFeed:self.feedDetailViewController.feed
                                content:self.textView.text];
    }
    [self dismissView];
}

- (void)dismissView{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Emoji 表情

- (SYEmojiPopover *)emojiView{
    if (!_emojiView) {
        _emojiView = [[SYEmojiPopover alloc] init];
        _emojiView.delegate = self;
    }
    return _emojiView;
}

//SYEmojiPopoverDelegate methods

-(void)emojiPopover:(SYEmojiPopover *)emojiPopover didClickedOnCharacter:(NSString *)character
{
    self.textView.text = [self.textView.text stringByAppendingString:character];
    [self textViewDidChange:self.textView];
}

- (IBAction)clickOnEmojiButton:(UIButton *)sender{
    [self.emojiView showFromPoint:CGPointMake(sender.center.x, CGRectGetHeight(self.view.frame) - self.keyboardHeight.constant - self.textViewBackgroundHeight.constant)
                           inView:self.view withTitle:@"点击插入表情"];
}

@end













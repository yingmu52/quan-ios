//
//  CommentAcessaryView.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-07.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "CommentAcessaryView.h"
#import "FetchCenter.h"
#import "UIImageView+WebCache.h"
@implementation CommentAcessaryView

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    CommentAcessaryView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    return view;
}

- (IBAction)tapOnBackground:(UITapGestureRecognizer *)sender {
    [self dismiss];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self.textField becomeFirstResponder];
}

- (void)dismiss{
    [self removeFromSuperview];
    [self.textField resignFirstResponder];
}

- (IBAction)sendPressed:(UIButton *)sender{
    [self.delegate didPressSend:self];
}


-(CommentAcessaryViewState)state{
    return self.feedInfoBackground.isHidden ? CommentAcessaryViewStateComment : CommentAcessaryViewStateReply;
}

- (void)setComment:(Comment *)comment{
    _comment = comment;
    [self.imageView sd_setImageWithURL:[[FetchCenter new] urlWithImageID:comment.owner.headUrl]];
    
    self.userNameLabel.text = comment.owner.ownerName;
    self.contentLabel.text = comment.content;
    self.timeLabel.text = [SystemUtil timeStringFromDate:comment.createTime];

}


#pragma mark - keyboard interaction notification 

- (void)awakeFromNib{
    [super awakeFromNib];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillHide:(NSNotification *)note{
    [self removeFromSuperview];
    NSLog(@"haha");
}

//- (void)keyboardWillShow:(NSNotification *)note {
//    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size];
//}

- (void)keyboardDidChange:(NSNotification *)note{
    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size];
}

- (void)updateFrameWithKeyboardSize:(CGSize)size{
    CGRect newFrame = self.frame;
    newFrame.size.height = [[UIScreen mainScreen] bounds].size.height - size.height;
    self.frame = newFrame;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end







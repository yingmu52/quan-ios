//
//  CommentAcessaryView.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-07.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "CommentAcessaryView.h"

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

- (void)awakeFromNib{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size];
}

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

- (void)dismiss{
    [self removeFromSuperview];
    [self.textField resignFirstResponder];
}
@end

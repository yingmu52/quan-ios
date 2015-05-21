//
//  FeedbackkAccessoryView.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedbackkAccessoryView.h"

@implementation FeedbackkAccessoryView

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    FeedbackkAccessoryView *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    [view setNeedsLayout];
    return view;
}


//#pragma mark - keyboard interaction notification
//
//- (void)awakeFromNib{
//    [super awakeFromNib];
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
//}
//
//- (void)keyboardWillShow:(NSNotification *)note {
//    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height];
//}
//
//- (void)keyboardDidChange:(NSNotification *)note{
//    [self updateFrameWithKeyboardSize:[[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height];
//}
//
//- (void)updateFrameWithKeyboardSize:(CGFloat)height{
//    NSLog(@"%@",@(height));
//    CGRect newFrame = self.frame;
//    newFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - height - newFrame.size.height;
//    self.frame = newFrame;
//}
//- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end

//
//  MSLabel.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSLabel.h"
#import "SystemUtil.h"
@implementation MSLabel

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    return (action == @selector(copy:));
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
    [self resetNormalState];
}

- (void)handleLongpress:(UILongPressGestureRecognizer *)longpress{
    if (longpress.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:self.frame inView:self.superview];
        [menuController setMenuVisible:YES animated:YES];
        self.backgroundColor = [SystemUtil colorFromHexString:@"#BCBBB8"];
    }
}

- (void)resetNormalState{
    self.backgroundColor = [UIColor clearColor];
    [self resignFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [menuController setMenuVisible:NO];
    }
}
@end

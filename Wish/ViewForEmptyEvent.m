//
//  ViewForEmptyEvent.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-28.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ViewForEmptyEvent.h"

@implementation ViewForEmptyEvent

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    ViewForEmptyEvent *view = [views firstObject];
    view.frame = frame;
    [view layoutIfNeeded];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 0.2f;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0,4.0f);
}

- (IBAction)buttonPressed:(id)sender{
    [self.delegate didPressButton:self];
}
@end

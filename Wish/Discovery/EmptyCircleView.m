//
//  EmptyCircleView.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-05.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "EmptyCircleView.h"

@implementation EmptyCircleView

+ (instancetype)instantiateFromNib:(CGRect)frame
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    EmptyCircleView *view = [views firstObject];
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
    
    //image view corner
    self.circleImageView.layer.cornerRadius = 10.0f;
    self.circleImageView.clipsToBounds = YES;
}

- (IBAction)buttonPressed:(id)sender{
}

@end

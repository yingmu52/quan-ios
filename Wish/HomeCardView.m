//
//  HomeCardView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardView.h"

@interface HomeCardView ()
@property (nonatomic,weak) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak,nonatomic) IBOutlet UILabel *countDownLabel;
@end

@implementation HomeCardView

-(void)setDataImage:(UIImage *)dataImage
{
    _dataImage = dataImage;
    self.imageView.image = dataImage;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
}
- (void)setCountDowns:(NSString *)countDowns
{
    _countDowns = countDowns;
    self.countDownLabel.text = countDowns;
}


+ (instancetype)instantiateFromNibWithSuperView:(UIView *)superView
{
    NSString *nibname = [NSString stringWithFormat:@"%@", [self class]];
    
    HomeCardView *contentView = [[[NSBundle mainBundle] loadNibNamed:nibname
                                                               owner:nil
                                                             options:nil] firstObject];
    
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:contentView];
    
    // This is important:
    // https://github.com/zhxnlai/ZLSwipeableView/issues/9
    NSDictionary *metrics = @{@"height" : @(superView.bounds.size.height),
                              @"width" : @(superView.bounds.size.width)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    [superView addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|[contentView(width)]"
      options:0
      metrics:metrics
      views:views]];
    [superView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|[contentView(height)]"
                          options:0
                          metrics:metrics
                          views:views]];

    return contentView;
}
- (void)awakeFromNib
{
    // Shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Corner Radius
    //    self.layer.cornerRadius = 10.0;
}

- (IBAction)dismissMoreView:(id)sender
{
    self.moreView.hidden = YES;
}

- (IBAction)showMoreView:(id)sender
{
    self.moreView.hidden = NO;
}

- (IBAction)deletePressed:(UIButton *)sender{
    [self.delegate homeCardView:self didPressedButton:sender];
}
@end

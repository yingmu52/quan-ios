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
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation HomeCardView


- (void)setPlan:(Plan *)plan
{
//    NSData *data = UIImageJPEGRepresentation(plan.image, 1);
//    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>%d",data.length);
    self.imageView.image = plan.image;
    self.titleLabel.text = plan.planTitle;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:plan.createDate];
    self.dateLabel.text = [NSString stringWithFormat:@"最后纪录时间：%@",dateString];

    
    self.subtitleLabel.text = @"已留0个努力瞬间";
    
    NSUInteger totalDays = [self daysBetween:plan.createDate and:plan.finishDate];
    NSUInteger pastDays = [self daysBetween:plan.createDate and:[NSDate date]];

    self.countDownLabel.text = [NSString stringWithFormat:@"剩余%u/%u",pastDays,totalDays];
    
}

- (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return [components day]+1;
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

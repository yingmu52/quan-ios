//
//  HomeCardView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeCardView.h"
#import "Theme.h"
#import "SystemUtil.h"
#import "Feed.h"
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
    _plan = plan;
    if (_plan) {
        self.imageView.image = _plan.image;
        self.titleLabel.text = _plan.planTitle;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateString = [formatter stringFromDate:plan.createDate];
        self.dateLabel.text = [NSString stringWithFormat:@"最后纪录时间：%@",dateString];
        
        
        self.subtitleLabel.text = [NSString stringWithFormat:@"已留下%@个努力瞬间",@(plan.feeds.count)];
        
        NSInteger totalDays = [SystemUtil daysBetween:_plan.createDate and:_plan.finishDate];
        NSInteger pastDays = [SystemUtil daysBetween:_plan.createDate and:[NSDate date]];
        
        
        NSDictionary *baseAttrs = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
        NSDictionary *countAttrs1 = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:26]};
        NSDictionary *countAttrs2 = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00bac3"]};
        
        NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:@"剩余 "
                                                                                  attributes:baseAttrs];
        
        NSMutableAttributedString *back = [[NSMutableAttributedString alloc] initWithString:@" 天"
                                                                                 attributes:baseAttrs];
        
        NSMutableAttributedString *mid = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%ld",(long)pastDays,(long)totalDays]
                                                                                attributes:countAttrs1];
        [mid addAttributes:countAttrs2
                     range:[mid.string rangeOfString:[NSString stringWithFormat:@"%ld",(long)pastDays]]];
        
        
        
        [final appendAttributedString:mid];
        [final appendAttributedString:back];
        self.countDownLabel.attributedText = final;

    }
}


- (void)awakeFromNib
{
    // Shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 0.2f;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(4.0f,4.0f);
//    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    // Corner Radius
    //    self.layer.cornerRadius = 10.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTaped)];
    [self addGestureRecognizer:tap];

}

- (IBAction)dismissMoreView:(id)sender
{
    self.moreView.hidden = YES;
    [self.delegate didDismissMoreView:self.moreView];
}

- (IBAction)showMoreView:(id)sender
{
    self.moreView.hidden = NO;
    [self.delegate didShowMoreView:self.moreView];
}

- (IBAction)deletePressed:(UIButton *)sender{
    [self.delegate homeCardView:self didPressedButton:sender];
    [self dismissMoreView:sender];
}

- (IBAction)finishPressed:(UIButton *)sender{
    [self.delegate homeCardView:self didPressedButton:sender];
}
- (void)backgroundTaped{
    if (self.moreView.isHidden) {
        [self.delegate didTapOnHomeCardView:self];
    }
}

@end

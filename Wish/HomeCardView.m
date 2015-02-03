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
    
    NSInteger totalDays = [SystemUtil daysBetween:plan.createDate and:plan.finishDate];
    NSInteger pastDays = [SystemUtil daysBetween:plan.createDate and:[NSDate date]];

    
    NSDictionary *baseAttrs = @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    NSDictionary *countAttrs1 = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:40]};
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTaped)];
    [self addGestureRecognizer:tap];

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
    [self dismissMoreView:sender];
}

- (void)backgroundTaped{
    [self.delegate didTapOnHomeCardView:self];
}

@end

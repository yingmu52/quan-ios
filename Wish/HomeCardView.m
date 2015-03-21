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
#import "UIImageView+WebCache.h"
#import "FetchCenter.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
@interface HomeCardView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak,nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak,nonatomic) IBOutlet UILabel *dateLabel;

@property (weak,nonatomic) IBOutlet UIView *canvasView;
@end

@implementation HomeCardView

- (void)setPlan:(Plan *)plan
{
//    NSData *data = UIImageJPEGRepresentation(plan.image, 1);
//    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>%d",data.length);
    _plan = plan;
    if (_plan) {
        if (!_plan.image){
            [self. imageView setImageWithURL:[[FetchCenter new] urlWithImageID:_plan.backgroundNum]
                 usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//            [self.imageView sd_setImageWithURL:[[[FetchCenter new] urlWithImageID:_plan.backgroundNum] placeholderImage:nil];
//            NSAssert(_plan.backgroundNum != nil, @"nil plan background id");
        }else{
            self.imageView.image = _plan.image;
        }
        
        self.titleLabel.text = _plan.planTitle;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateString = [formatter stringFromDate:plan.createDate];
        self.dateLabel.text = [NSString stringWithFormat:@"最后纪录时间：%@",dateString];
        
        
        self.subtitleLabel.text = [NSString stringWithFormat:@"%@个努力瞬间",@(plan.feeds.count)];
        
        
        
        NSDictionary *baseAttrs = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
        NSDictionary *attrs = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:26],
                                NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00bac3"]};

        NSInteger totalDays = [SystemUtil daysBetween:_plan.createDate and:_plan.finishDate];
        NSInteger pastDays = [SystemUtil daysBetween:_plan.createDate and:[NSDate date]];
        NSInteger results = totalDays - pastDays;
//        NSDictionary *countAttrs1 = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:26]};
//        NSDictionary *countAttrs2 = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00bac3"]};
        
        NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:(results >= 0 ? @"剩余 " : @"过期 ") attributes:baseAttrs];
        NSMutableAttributedString *back = [[NSMutableAttributedString alloc] initWithString:@" 天" attributes:baseAttrs];
        NSAttributedString *mid = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@(ABS(results))] attributes:attrs];
//        NSMutableAttributedString *mid = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld/%ld",(long)pastDays,(long)totalDays]
//                                                                                attributes:countAttrs1];
//        [mid addAttributes:countAttrs2
//                     range:[mid.string rangeOfString:[NSString stringWithFormat:@"%ld",(long)pastDays]]];
        
        [final appendAttributedString:mid];
        [final appendAttributedString:back];
        self.countDownLabel.attributedText = final;

    }
}


- (void)awakeFromNib
{
    // Shadow
    self.canvasView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.canvasView.layer.shadowRadius = 2.0f;
    self.canvasView.layer.shadowOpacity = 0.2f;
    self.canvasView.layer.masksToBounds = NO;
    self.canvasView.layer.shadowOffset = CGSizeMake(4.0f,4.0f);
//    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    // Corner Radius
    //    self.layer.cornerRadius = 10.0;
    
}


- (IBAction)cameraPressed:(UIButton *)sender{
    [self.delegate didPressCameraOnCard:self];
}
@end

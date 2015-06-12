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
#import "UIImageView+WebCache.h"
@interface HomeCardView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak,nonatomic) IBOutlet UIView *canvasView;
@end

@implementation HomeCardView

- (void)setPlan:(Plan *)plan
{
    _plan = plan;
    if (_plan) {
        if (!_plan.image){
            [self.imageView sd_setImageWithURL:[[FetchCenter new] urlWithImageID:_plan.backgroundNum]];
        }else{
            self.imageView.image = _plan.image;
        }
        self.titleLabel.text = _plan.planTitle;
        self.subtitleLabel.text = [NSString stringWithFormat:@"%@条记录\t%@人关注",plan.tryTimes,plan.followCount];
    }
}


- (void)awakeFromNib
{
    [super awakeFromNib];
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

//
//  MSTableViewCell.m
//  Stories
//
//  Created by Xinyi Zhuang on 8/29/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSTableViewCell.h"
#import "SystemUtil.h"
@implementation MSTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.ms_textView.textContainerInset = UIEdgeInsetsZero;
    self.ms_imageView1.contentMode = UIViewContentModeScaleAspectFill;
    self.ms_imageView2.contentMode = UIViewContentModeScaleAspectFill;
    self.ms_cardBackgroundView.referenceBadgeView = self.ms_imageView2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//
//- (void)prepareForReuse{
//    [super prepareForReuse];
//    self.ms_title.hidden = NO;
//    self.ms_subTitle.hidden = NO;
//    self.ms_statusLabel.hidden = NO;
//    self.ms_dateLabel.hidden = NO;
//    self.ms_textView.hidden = NO;
//    
//    self.ms_imageView1.hidden = NO;
//    self.ms_imageView2.hidden = NO;
//    self.ms_cardBackgroundView.hidden = NO;
//
//}
@end

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
    self.ms_textView.editable = NO;
    self.ms_textView.selectable = NO;
    self.ms_textView.scrollEnabled = NO;
    self.ms_textView.userInteractionEnabled = NO;
    
    
    self.ms_imageView1.contentMode = UIViewContentModeScaleAspectFill;
    self.ms_imageView1.clipsToBounds = YES;
    self.ms_imageView1.layer.cornerRadius = 3.0f;
    
    self.ms_imageView2.contentMode = UIViewContentModeScaleAspectFill;
    self.ms_imageView2.clipsToBounds = YES;
    self.ms_imageView2.layer.cornerRadius = 3.0f;
    self.ms_cardBackgroundView.referenceBadgeView = self.ms_imageView2;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)prepareForReuse{
    [super prepareForReuse];
    self.ms_imageView1.image = nil;
    self.ms_imageView2.image = nil;
    self.ms_FeatherImage.image = nil;
    
}
@end

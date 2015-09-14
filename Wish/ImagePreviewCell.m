//
//  ImagePreviewCell.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePreviewCell.h"

@implementation ImagePreviewCell

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}
@end

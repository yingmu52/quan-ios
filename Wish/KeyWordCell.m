//
//  KeyWordCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-28.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "KeyWordCell.h"
#import "Theme.h"
@implementation KeyWordCell

//
//- (void)setPatchImageForButtons:(UIView *)button
//{
//    
//    
//    UIImage *patchImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25.0,25.0,25.0,25.0)
//                                                resizingMode:UIImageResizingModeTile];
//    [button setBackgroundImage:patchImage
//                      forState:UIControlStateNormal];
//}


- (void)awakeFromNib{
    [super awakeFromNib];
    
    UIImage *image = [Theme tipsBackgroundImage];
    UIImage *patchImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25.0,25.0,25.0,23.0)
                                                resizingMode:UIImageResizingModeTile];
    self.backgroundImageView.image = patchImage;
}
@end

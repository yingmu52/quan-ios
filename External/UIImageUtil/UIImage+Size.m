//
//  UIImage+Size.m
//  Stories
//
//  Created by xfan on 2017/1/16.
//  Copyright © 2017年 Xinyi Zhuang. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)

- (CGSize)realSize
{
    return CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
}

/*绘制大小（根据retina屏幕计算出正确的绘制大小）*/
- (CGSize)drawSize
{
    CGSize originalSize = [self realSize];
    CGFloat width = MAX(1, floorf(originalSize.width / [UIScreen mainScreen].scale));
    CGFloat height = MAX(1, floorf(originalSize.height / [UIScreen mainScreen].scale));
    return CGSizeMake(width, height);
}

- (CGFloat)normalScaleFactor
{
    CGFloat shortSide = 1600;
    CGFloat longSide = 10000;
    CGFloat scale = 0.0f;
    
    CGSize imageSize = self.realSize;
    
    if(imageSize.width / imageSize.height > 2) {
        if(imageSize.width / imageSize.height > longSide / shortSide) {
            scale = longSide / imageSize.width;
        } else {
            scale = shortSide / imageSize.height;
        }
    } else if(imageSize.width / imageSize.height < 0.5) {
        if(imageSize.width / imageSize.height > longSide / shortSide) {
            scale = shortSide / imageSize.width;
        } else {
            scale = longSide / imageSize.height;
        }
    } else {
        scale = shortSide / MAX(imageSize.width, imageSize.height);
    }
    
//    if (self.realSize.width > self.realSize.height) {
//        if(self.realSize.width / self.realSize.height > longSide / shortSide) {
//            scale = longSide / self.realSize.width;
//        } else {
//            scale = shortSide / self.realSize.height;
//        }
//    } else {
//        if(self.realSize.height / self.realSize.width > longSide / shortSide) {
//            scale = longSide / self.realSize.height;
//        } else {
//            scale = shortSide / self.realSize.width;
//        }
//    
//    }
    
    if (scale > 1) {
        scale = 1;
    }
    
    return scale;
}


- (BOOL)isAlphaChanelImage
{
    BOOL isAlphaChanel = YES;
    CGImageRef cgImage = self.CGImage;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);
    
    switch (alphaInfo) {
        case kCGImageAlphaNone:
        case kCGImageAlphaNoneSkipLast:
        case kCGImageAlphaNoneSkipFirst:
            isAlphaChanel = NO;
            break;
            
        default:
            break;
    }
    
    return isAlphaChanel;
}


@end

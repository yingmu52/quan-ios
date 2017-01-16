//
//  UIImage+Size.h
//  Stories
//
//  Created by xfan on 2017/1/16.
//  Copyright © 2017年 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Size)

/*真实大小*/
- (CGSize)realSize;

/*绘制大小（根据retina屏幕计算出正确的绘制大小）*/
- (CGSize)drawSize;

- (BOOL)isAlphaChanelImage;


- (CGFloat)normalScaleFactor;

@end

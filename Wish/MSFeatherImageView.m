//
//  MSFeatherImageView.m
//  Image-Test
//
//  Created by Xinyi Zhuang on 9/13/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSFeatherImageView.h"
#import "MSCircularGradientLayer.h"
@implementation MSFeatherImageView

-(void)setImage:(UIImage *)image{
    [super setImage:[self cropImage:image]];
}

- (UIImage *)cropImage:(UIImage *)image{
    //crop image
    CGSize imgSize = image.size;
    CGFloat w = imgSize.width;
    CGFloat h = imgSize.height;
    CGFloat sizeScale = 0.618;
    CGFloat originScale = 1 - sizeScale;
    CGRect rect = CGRectMake(w * originScale, h * originScale, w * sizeScale, h * sizeScale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect halfCircleRect = CGRectMake(0, - self.frame.size.height,
                                       CGRectGetWidth(self.frame) * 2,
                                       CGRectGetHeight(self.frame) * 2);
    [self addMaskToBounds:halfCircleRect];
}


- (void)addMaskToBounds:(CGRect)maskBounds
{
    MSCircularGradientLayer *cgl = [MSCircularGradientLayer new];
    cgl.frame = maskBounds;
    cgl.ms_ThemeColor = [UIColor blueColor];
    cgl.backgroundColor = [UIColor clearColor].CGColor;
    [cgl setNeedsDisplay];
    [self.layer setMask:cgl];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

@end

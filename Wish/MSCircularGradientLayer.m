//
//  MSCircularGradientLayer.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/13/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSCircularGradientLayer.h"

@implementation MSCircularGradientLayer


- (void)drawInContext:(CGContextRef)ctx{
    CGFloat radius = MIN(CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)) * 0.5;
    CGFloat featherLocations[2] = {0,1};
    
    
    CGColorSpaceRef baseColorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *gradientColors = @[(id)[UIColor colorWithWhite:1 alpha:1].CGColor,
                                (id)[UIColor colorWithWhite:0 alpha:0].CGColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(baseColorSpace,
                                                        (__bridge CFArrayRef)gradientColors,
                                                        featherLocations);
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    CGContextDrawRadialGradient(ctx,
                                gradient,
                                center,
                                0,
                                center,
                                radius,
                                kCGGradientDrawsAfterEndLocation);
    CGColorSpaceRelease(baseColorSpace);
    CGGradientRelease(gradient);
}



@end

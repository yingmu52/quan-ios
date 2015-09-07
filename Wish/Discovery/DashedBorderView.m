//
//  DashedBorderView.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-07.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DashedBorderView.h"
#import "SystemUtil.h"
static CGFloat const kDashedBorderWidth     = (2.0f);
static CGFloat const kDashedPhase           = (0.0f);
static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
static size_t const kDashedCount            = (2.0f);


@implementation DashedBorderView

- (void)drawRect:(CGRect)rect {
    UIColor *lineColor = [SystemUtil colorFromHexString:@"#00C1A8"];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kDashedBorderWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineDash(context, kDashedPhase, kDashedLinesLength, kDashedCount) ;
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);

}


@end

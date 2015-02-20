//
//  TriangleCutoutView.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "TriangleCutoutView.h"

@implementation TriangleCutoutView


- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}
- (void)drawRect:(CGRect)rect {

    CGFloat tipWidth = self.referenceBadgeView.frame.size.width/2;
    CGFloat tipHeight = self.referenceBadgeView.frame.size.height/2;
    CGPoint midPoint = CGPointMake(rect.origin.x + tipWidth/2, self.referenceBadgeView.center.y);
    
    CGFloat leftEdge = rect.origin.x + tipWidth;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(leftEdge,rect.origin.y)];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width,rect.origin.y)];
    [bezierPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height)];
    [bezierPath addLineToPoint:CGPointMake(leftEdge,rect.origin.y + rect.size.height)];
    
    
    [bezierPath addLineToPoint:CGPointMake(leftEdge,midPoint.y + tipHeight/2)];
    [bezierPath addLineToPoint:CGPointMake(midPoint.x, midPoint.y)];
    [bezierPath addLineToPoint:CGPointMake(leftEdge, midPoint.y - tipHeight/2)];
    [bezierPath addLineToPoint:CGPointMake(leftEdge, rect.origin.y)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    shapeLayer.bounds = rect;
    shapeLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    shapeLayer.position = CGPointMake(0.0f, 0.0f);

    
    
    //draw shadows
    shapeLayer.shadowColor = [UIColor blackColor].CGColor;
    shapeLayer.shadowRadius = 1.0f;
    shapeLayer.shadowOpacity = 0.15f;
    shapeLayer.masksToBounds = NO;
    shapeLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    [self.layer addSublayer:shapeLayer];
    [self.layer insertSublayer:shapeLayer atIndex:0];


}


@end

//
//  ButtonWithPathedImage.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-02-26.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "ButtonWithPathedImage.h"

@implementation ButtonWithPathedImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    //拉伸背影图，注意这个做法需要背影图保持自己的真实高度
    UIImage *backgroundImage = [self backgroundImageForState:UIControlStateNormal];
    if (backgroundImage) {
        
        CGFloat top = CGRectGetHeight(self.frame) * 0.5;
        CGFloat buttom = CGRectGetHeight(self.frame) * 0.5;
        
        CGFloat left = CGRectGetWidth(self.frame) * 0.5;
        CGFloat right = CGRectGetWidth(self.frame) * 0.5;

        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,buttom,right)];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
}
@end

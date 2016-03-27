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
        CGFloat horizontal = backgroundImage.size.width * 0.5;
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0,horizontal,0,horizontal)];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
}
@end

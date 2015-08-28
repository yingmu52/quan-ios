//
//  PreviewCell.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-25.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "PreviewCell.h"
#import "SystemUtil.h"
@implementation PreviewCell

- (UIColor *)borderColor{
    if (!_borderColor) {
        _borderColor = [SystemUtil colorFromHexString:@"#00C1A8"];
    }
    return _borderColor;
}

- (void)showHeightlightedState{
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = 4.0f;
}

- (void)showNormalState{
    self.layer.borderColor = nil;
    self.layer.borderWidth = 0.0f;
}

- (void)setSelected:(BOOL)selected{
    if (selected) {
        [self showHeightlightedState];
    }else{
        [self showNormalState];
    }
}
@end

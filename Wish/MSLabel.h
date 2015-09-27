//
//  MSLabel.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSLabel : UILabel
- (void)handleLongpress:(UILongPressGestureRecognizer *)longpress;
- (void)resetNormalState;
@end

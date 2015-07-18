//
//  FeedDetailCell.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-05.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailCell.h"

@implementation FeedDetailCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.contentTextView.textContainerInset = UIEdgeInsetsZero;
}
@end

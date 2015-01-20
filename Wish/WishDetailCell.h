//
//  WishDetailCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WishDetailCell : UITableViewCell

@property (nonatomic) BOOL isWidgetVisible;
-(void)showLikeAndComment;

- (void)dismissLikeAndComment;


- (void)moveWidget:(BOOL)toVisible;
@end

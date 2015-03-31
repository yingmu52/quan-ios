//
//  WishDetailCell.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-19.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
@interface WishDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
//@property (nonatomic) BOOL isWidgetVisible;
@property (nonatomic,strong) Feed *feed;

//-(void)showLikeAndComment;
//- (void)dismissLikeAndComment;
//- (void)moveWidget:(BOOL)toVisible;
@end

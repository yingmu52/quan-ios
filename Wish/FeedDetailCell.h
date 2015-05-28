//
//  FeedDetailCell.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-05.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FEEDDETAILCELLID @"FeedDetailCell"
@interface FeedDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

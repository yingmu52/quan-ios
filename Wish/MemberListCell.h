//
//  MemberListCell.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-09.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIImageView *headImageView;
@property (nonatomic,weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *moreIcon;
@end

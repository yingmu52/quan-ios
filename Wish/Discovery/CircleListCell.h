//
//  CircleListCell.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-02-26.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleListCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIImageView *circleListImageView;
@property (nonatomic,weak) IBOutlet UILabel *circleListTitle;
@property (nonatomic,weak) IBOutlet UILabel *circleListSubtitle;
@end

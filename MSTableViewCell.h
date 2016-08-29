//
//  MSTableViewCell.h
//  Stories
//
//  Created by Xinyi Zhuang on 8/29/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *ms_imageView1;
@property (nonatomic,weak) IBOutlet UIImageView *ms_imageView2;
@property (nonatomic,weak) IBOutlet UILabel *ms_title;
@property (nonatomic,weak) IBOutlet UILabel *ms_subTitle;
@property (nonatomic,weak) IBOutlet UILabel *ms_dateLabel;
@property (nonatomic,weak) IBOutlet UITextView *ms_textView;
@end

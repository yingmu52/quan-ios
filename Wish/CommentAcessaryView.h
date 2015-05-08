//
//  CommentAcessaryView.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-07.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAcessaryView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
+ (instancetype)instantiateFromNib:(CGRect)frame;
@end

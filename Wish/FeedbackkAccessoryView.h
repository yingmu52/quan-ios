//
//  FeedbackkAccessoryView.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackkAccessoryView : UIView
@property (nonatomic,weak) IBOutlet UITextField *textField;

+ (instancetype)instantiateFromNib:(CGRect)frame;
@end

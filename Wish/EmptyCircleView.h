//
//  EmptyCircleView.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-05.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmptyCircleView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;
@property (weak, nonatomic) IBOutlet UILabel *circleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *circleDescriptionLabel;
+ (instancetype)instantiateFromNib:(CGRect)frame;
@end

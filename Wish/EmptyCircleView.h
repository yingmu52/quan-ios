//
//  EmptyCircleView.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-05.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmptyCircleView;
@protocol EmptyCircleViewDelegate <NSObject>
- (void)didPressedButtonOnEmptyCircleView:(EmptyCircleView *)emptyView;
@end

@interface EmptyCircleView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;
@property (weak, nonatomic) IBOutlet UILabel *circleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *circleDescriptionLabel;
@property (weak, nonatomic) id <EmptyCircleViewDelegate> delegate;
+ (instancetype)instantiateFromNib:(CGRect)frame;
@end

//
//  StationViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-19.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"

@interface StationViewController : MSSuperViewController <UIGestureRecognizerDelegate>

//从主页传过来的参数
@property (nonatomic,weak) UILongPressGestureRecognizer *longPress;
@property (nonatomic,weak) Plan *plan;


@property (nonatomic,weak) IBOutlet UIView *cardView;
@property (nonatomic,weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic,weak) IBOutlet UIImageView *deleteButton;
@property (nonatomic,weak) IBOutlet UIImageView *finishButton;

@end

//
//  CircleCreationViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-01.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSuperViewController.h"

@class CircleCreationViewController;
@protocol CircleCreationViewControllerDelegate <NSObject>
- (void)didFinishCreatingCircle;
@end
@interface CircleCreationViewController : MSSuperViewController
@property (nonatomic,weak) id <CircleCreationViewControllerDelegate> delegate;
@end

//
//  CirclePickerViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-25.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"
#import "CircleListViewController.h"

@protocol CirclePickerViewControllerDelegate <NSObject>
- (void)didFinishPickingCircle:(Circle *)circle;
@end


@interface CirclePickerViewController : CircleListViewController
@property (nonatomic,weak) id <CirclePickerViewControllerDelegate> delegate;
@end

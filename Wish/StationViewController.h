//
//  StationViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-19.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "MSSuperViewController.h"

typedef enum {
    StationViewSelectionNone = -1,
    StationViewSelectionDelete = 0,
    StationViewSelectionFinish = 1
}StationViewSelection;


@class StationViewController;
@protocol StationViewControllerDelegate
- (void)didFinishAction:(StationViewSelection)selection forIndexPath:(NSIndexPath *)indexPath;
@end

@interface StationViewController : UIViewController <UIGestureRecognizerDelegate>

//从主页传过来的参数
@property (nonatomic,weak) UILongPressGestureRecognizer *longPress;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) UIImage *cardImage;
@property (nonatomic,weak) id <StationViewControllerDelegate> delegate;

@end

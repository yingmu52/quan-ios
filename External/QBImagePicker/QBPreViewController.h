//
//  QBPreViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePreviewController.h"

@class QBPreViewController;
@protocol QBPreViewControllerDelegate <NSObject>
- (void)configureCell:(ImagePreviewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfCell;
- (BOOL)hasAssetBeingSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)performActionForAssetAtIndexPath:(NSIndexPath *)indexPath shouldSelect:(BOOL)shouldSelect;
- (BOOL)shouldSelectIndexPath:(NSIndexPath *)indexPath;
- (void)InQBPreviewDidPressDone;
@optional

@end

@interface QBPreViewController : ImagePreviewController
@property (nonatomic,weak) id <QBPreViewControllerDelegate> qbDelegate;
@end

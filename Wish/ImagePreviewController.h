//
//  ImagePreviewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

@import UIKit;
#import "Theme.h"
#import "NavigationBar.h"
#import "ImagePreviewCell.h"

@protocol ImagePreviewControllerDelegate <NSObject>

@optional
- (void)didRemoveImageAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface ImagePreviewController : UICollectionViewController;
@property (nonatomic,strong) NSMutableArray *assets;
@property (nonatomic,strong) NSIndexPath *entryIndexPath;
@property (nonatomic,weak) id <ImagePreviewControllerDelegate> delegate;
@end

//
//  ImagePreviewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

@import UIKit;

@protocol ImagePreviewControllerDelegate <NSObject>

@optional
- (void)didRemoveImageAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface ImagePreviewController : UICollectionViewController;
@property (nonatomic,strong) NSMutableArray *previewImages;
@property (nonatomic,strong) NSIndexPath *entryIndexPath;
@property (nonatomic,weak) id <ImagePreviewControllerDelegate> delegate;
@end

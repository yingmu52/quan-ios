//
//  ImagePicker.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSInteger defaultMaxImageSelectionAllowed = 8;
@class ImagePickerDelegate;
@protocol ImagePickerDelegate <NSObject>
@optional
- (void)didFinishPickingImage:(NSArray *)images;
- (void)didFailPickingImage;
@end
@interface ImagePicker : NSObject <UIImagePickerControllerDelegate,UINavigationBarDelegate>

@property (nonatomic,weak) id<ImagePickerDelegate>imagePickerDelegate;

- (void)showCamera:(UIViewController *)controller;
- (void)showPhotoLibrary:(UIViewController *)controller maxImageCount:(NSInteger )count;
- (void)showPhotoLibrary:(UIViewController *)controller;
- (void)startPickingImageFromLocalSourceFor:(UIViewController<ImagePickerDelegate>*)controller;
@end

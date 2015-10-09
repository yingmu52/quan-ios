//
//  ImagePicker.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageCompat.h"
#import "QBImagePickerController.h"
@import Photos;

static const NSInteger defaultMaxImageSelectionAllowed = 8;

@class ImagePickerDelegate;
@protocol ImagePickerDelegate <NSObject>
@optional
- (void)didFailPickingImage;
- (void)didFinishPickingPhAssets:(NSMutableArray *)assets;
@end

@interface ImagePicker : NSObject <UIImagePickerControllerDelegate,UINavigationBarDelegate>

@property (nonatomic,weak) id<ImagePickerDelegate>imagePickerDelegate;

- (void)showCamera:(UIViewController *)controller;
- (void)showPhotoLibrary:(UIViewController *)controller maxImageCount:(NSInteger )count;
- (void)showPhotoLibrary:(UIViewController *)controller;
//- (void)startPickingImageFromLocalSourceFor:(UIViewController<ImagePickerDelegate>*)controller;
- (void)showImagePickerForUploadProfileImage:(UIViewController *)controller type:(UIImagePickerControllerSourceType)type;
@end

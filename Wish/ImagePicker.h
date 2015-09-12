//
//  ImagePicker.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImagePickerDelegate;
@protocol ImagePickerDelegate <NSObject>
@optional
- (void)didFinishPickingImage:(NSArray *)images;
- (void)didFailPickingImage;
@end
@interface ImagePicker : NSObject <UIImagePickerControllerDelegate,UINavigationBarDelegate>

@property (nonatomic,weak) id<ImagePickerDelegate>imagePickerDelegate;

- (void)showCameraOn:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller type:(UIImagePickerControllerSourceType)type;
- (void)startPickingImageFromLocalSourceFor:(UIViewController<ImagePickerDelegate>*)controller;
@end

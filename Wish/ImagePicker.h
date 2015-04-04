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
- (void)didFinishPickingImage:(UIImage *)image;
@optional
- (void)didFailPickingImage;
@end
@interface ImagePicker : NSObject <UIImagePickerControllerDelegate,UINavigationBarDelegate>

@property (nonatomic,weak) id<ImagePickerDelegate>imagePickerDelegate;


+ (void)startPickingImageFromLocalSourceFor:(UIViewController<ImagePickerDelegate>*)controller;
@end

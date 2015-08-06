//
//  ImagePicker.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePicker.h"
#import "TWPhotoPickerController.h"
#import "UIActionSheet+Blocks.h"
#import "UIImagePickerController+DelegateBlocks.h"
#import "UIImage+Resize.h"
@interface ImagePicker () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ImagePicker


- (void)showCameraOn:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller type:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = type;
    ipc.delegate = self;
    ipc.allowsEditing = YES;

    if (type == UIImagePickerControllerSourceTypeCamera) {
        ipc.showsCameraControls = YES;
    }
    [ipc useBlocksForDelegate]; // important !
    [ipc onDidFinishPickingMediaWithInfo:^(UIImagePickerController *picker, NSDictionary *info) {
        [self hideStatusBar];
        [controller dismissViewControllerAnimated:YES completion:^{
            UIImage *capturedImage;
//            if (type == UIImagePickerControllerSourceTypeCamera){
                capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
//            }else if (type == UIImagePickerControllerSourceTypePhotoLibrary || type == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
//                UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
//                capturedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit
//                                                            bounds:CGSizeMake(image.size.width * 0.25, image.size.height * 0.25)
//                                              interpolationQuality:kCGInterpolationHigh];
//            }
            
            [self.imagePickerDelegate didFinishPickingImage:capturedImage];
        }];
    }];
    [ipc onDidCancel:^(UIImagePickerController *picker) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [self hideStatusBar];
        [self.imagePickerDelegate didFailPickingImage];
    }];
    
    [ipc onDidShowViewController:^(UINavigationController *navigationController, UIViewController *viewController, BOOL animated) {
        [self hideStatusBar];
    }];
    [controller presentViewController:ipc animated:YES completion:nil];
    
}


- (void)hideStatusBar{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
#define take_photo @"拍照"
#define choose_album @"从手机相册选择"

+ (void)startPickingImageFromLocalSourceFor:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller{
    [UIActionSheet showInView:controller.view
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[take_photo,choose_album]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        ImagePicker *picker = [[ImagePicker alloc] init];
        picker.imagePickerDelegate = controller;
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:take_photo]) {
            [picker showCameraOn:controller type:UIImagePickerControllerSourceTypeCamera];
        }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose_album]) {
            [picker showCameraOn:controller type:UIImagePickerControllerSourceTypePhotoLibrary];
        }else{
            [picker.imagePickerDelegate didFailPickingImage];
        }
    }];
}

#pragma mark - image compression
/*
- (UIImage *)compressImage:(UIImage *)image{
    CGFloat actualHeight = image.size.height;
    CGFloat actualWidth = image.size.width;
//    UIImage *outputImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 1.0)];
    CGFloat thresHold = 1e5;
    NSLog(@"Image Size : %@",NSStringFromCGSize(image.size));
    UIImage *outputImage;
    if (actualHeight*actualWidth <= thresHold){
        //no compression is needed
        outputImage = image;
    }else{
        outputImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.9)];
        CGFloat maxHeight = [UIScreen mainScreen].bounds.size.width;
        CGFloat maxWidth = maxHeight;
        CGFloat imgRatio = actualWidth/actualHeight;
        CGFloat maxRatio = maxWidth/maxHeight;
        CGFloat compressionQuality = 1.0;//90 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        [image drawInRect:rect];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        outputImage = [UIImage imageWithData:imageData];
    }
    
    return outputImage;
}
*/
@end

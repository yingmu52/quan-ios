//
//  ImagePicker.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePicker.h"
#import "UIActionSheet+Blocks.h"
#import "ELCImagePickerController.h"
#import "SDWebImageCompat.h"
@import AssetsLibrary;
@interface ImagePicker () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,ELCImagePickerControllerDelegate>
@property (nonatomic,strong) NSArray *images;
@end

@implementation ImagePicker


- (void)showCameraOn:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller type:(UIImagePickerControllerSourceType)type{
    if (type == UIImagePickerControllerSourceTypeCamera) {
        dispatch_main_async_safe(^{
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType = type;
            ipc.delegate = self;
            ipc.showsCameraControls = YES;
            [controller presentViewController:ipc animated:YES completion:nil];            
        });
        
    }else if (type == UIImagePickerControllerSourceTypePhotoLibrary) {
        // Create the image picker
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        
        elcPicker.maximumImagesCount = 4; //Set the maximum number of images to select, defaults to 4
        elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
        elcPicker.imagePickerDelegate = self;
        
        //Present modally
        [controller presentViewController:elcPicker animated:YES completion:nil];
    }
    
}

#pragma mark - ELCImagePickerControllerDelegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    if ([self.imagePickerDelegate isKindOfClass:[UIViewController class]]) {
        [picker dismissViewControllerAnimated:YES completion:^{
            NSMutableArray *images = [NSMutableArray array];
            for (NSDictionary *dict in info) {
                if (dict[UIImagePickerControllerMediaType] == ALAssetTypePhoto) {
                    [images addObject:[dict objectForKey:UIImagePickerControllerOriginalImage]];
                }
            }
            [self.imagePickerDelegate didFinishPickingImage:images];
         }];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self failPickingImage];
}

#pragma mark - UIImagePickerViewController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if ([self.imagePickerDelegate isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self.imagePickerDelegate;
        [vc dismissViewControllerAnimated:YES completion:^{
            UIImage *capturedImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
            [self.imagePickerDelegate didFinishPickingImage:@[capturedImage]];
        }];

    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self failPickingImage];
}

- (void)failPickingImage{
    if ([self.imagePickerDelegate isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self.imagePickerDelegate;
        [vc dismissViewControllerAnimated:YES completion:^{
            if ([self.imagePickerDelegate respondsToSelector:@selector(didFailPickingImage)]) {
                [self.imagePickerDelegate didFailPickingImage];
            }
        }];
    }
}

#define take_photo @"拍照"
#define choose_album @"从手机相册选择"

- (void)startPickingImageFromLocalSourceFor:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller{
    [UIActionSheet showInView:controller.view
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[take_photo,choose_album]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:take_photo]) {
            [self showCameraOn:controller type:UIImagePickerControllerSourceTypeCamera];
        }
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose_album]) {
            [self showCameraOn:controller type:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }];
}

@end

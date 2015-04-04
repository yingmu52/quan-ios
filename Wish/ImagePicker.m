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
@interface ImagePicker () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ImagePicker



- (void)showCameraOn:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.allowsEditing = YES;
    ipc.showsCameraControls = YES;
    [ipc useBlocksForDelegate]; // important !
    [ipc onDidFinishPickingMediaWithInfo:^(UIImagePickerController *picker, NSDictionary *info) {
        [controller dismissViewControllerAnimated:YES completion:^{
            UIImage *capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
            UIImage *compressed = [UIImage imageWithData:UIImageJPEGRepresentation(capturedImage, 0.1)];
            //NSLog(@"%@",NSStringFromCGSize(editedImage.size));
            [self.imagePickerDelegate didFinishPickingImage:compressed];
        }];
    }];
    [controller presentViewController:ipc animated:YES completion:nil];
    
}


#define take_photo @"拍照"
#define choose_album @"从手机相册选择"

+ (void)startPickingImageFromLocalSourceFor:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller{
    [UIActionSheet showInView:controller.view
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[take_photo,choose_album]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         ImagePicker *picker = [[ImagePicker alloc] init];
                         picker.imagePickerDelegate = controller;
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:take_photo]) {
            [picker showCameraOn:controller];
        }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose_album]) {
            TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
            photoPicker.cropBlock = ^(UIImage *image) {
                //do something
                UIImage *compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.1)];
                [picker.imagePickerDelegate didFinishPickingImage:compressedImage];
            };
            [controller presentViewController:photoPicker animated:YES completion:nil];
        }}];
}
@end

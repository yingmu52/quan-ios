//
//  ImagePicker.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePicker.h"
#import "UIActionSheet+Blocks.h"
#import "SDWebImageCompat.h"
#import "QBImagePickerController.h"
@import AssetsLibrary;
@interface ImagePicker () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,QBImagePickerControllerDelegate>
@property (nonatomic,strong) NSArray *images;
@end

@implementation ImagePicker

#pragma mark - new method

- (void)showCamera:(UIViewController *)controller{
    dispatch_main_async_safe(^{
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.delegate = self;
        ipc.showsCameraControls = YES;
        [controller presentViewController:ipc animated:YES completion:nil];
    });
}

- (void)showImagePickerForUploadProfileImage:(UIViewController *)controller type:(UIImagePickerControllerSourceType)type{
    dispatch_main_async_safe(^{
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = type;
        ipc.delegate = self;
//        ipc.showsCameraControls = YES;
        ipc.allowsEditing = YES;
        [controller presentViewController:ipc animated:YES completion:nil];
    });
}
- (void)showPhotoLibrary:(UIViewController *)controller maxImageCount:(NSInteger )count{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = count;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.numberOfColumnsInPortrait = 4;
    imagePickerController.assetCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary), // Camera Roll
                                                      @(PHAssetCollectionSubtypeAlbumMyPhotoStream), // My Photo Stream
                                                      @(PHAssetCollectionSubtypeSmartAlbumPanoramas), // Panoramas
                                                      @(PHAssetCollectionSubtypeSmartAlbumBursts) // Bursts
                                                      ];
    [controller presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)showPhotoLibrary:(UIViewController *)controller{
    [self showPhotoLibrary:controller maxImageCount:defaultMaxImageSelectionAllowed]; //默认可选取的照片数
}

#pragma QBImagePickerController

- (BOOL)qb_imagePickerController:(QBImagePickerController *)imagePickerController shouldSelectAsset:(PHAsset *)asset{
    if (imagePickerController.numberOfSelectedAsset == imagePickerController.maximumNumberOfSelection) {
        NSString *titleText = [NSString stringWithFormat:@"最多只能选%@张照片哦",@(imagePickerController.maximumNumberOfSelection)];
        [[[UIAlertView alloc] initWithTitle:titleText message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return NO;
    }
    return YES;
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    if ([self.imagePickerDelegate isKindOfClass:[UIViewController class]]) {
        [imagePickerController dismissViewControllerAnimated:YES completion:^{
            PHImageManager *manager = [PHImageManager defaultManager];
            NSMutableArray *arrayOfUIImages = [NSMutableArray arrayWithCapacity:assets.count];
            
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            
            
            for (PHAsset *asset in assets) {
                
                [manager requestImageForAsset:asset
                                   targetSize:PHImageManagerMaximumSize
                                  contentMode:PHImageContentModeAspectFit
                                      options:options
                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                    [arrayOfUIImages addObject:result];
                                    if (arrayOfUIImages.count == assets.count) {
                                        [self.imagePickerDelegate didFinishPickingImage:arrayOfUIImages];
                                    }
                                }];
                
            }
            
        }];
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerViewController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if ([self.imagePickerDelegate isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self.imagePickerDelegate;
        [vc dismissViewControllerAnimated:YES completion:^{
            UIImage *originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
            UIImage *editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
            UIImage *capturedImage = editedImage ? editedImage : originalImage;
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
            [self showCamera:controller];
        }
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose_album]) {
            [self showPhotoLibrary:controller];
        }
    }];
}

@end

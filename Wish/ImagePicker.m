//
//  ImagePicker.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-04-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePicker.h"
@interface ImagePicker () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,QBImagePickerControllerDelegate>
@property (nonatomic,strong) NSArray *images;
@end

@implementation ImagePicker

#pragma mark - new method

- (BOOL)hasPermissionAccess{
    if ([PHPhotoLibrary authorizationStatus] == (PHAuthorizationStatusDenied | PHAuthorizationStatusNotDetermined)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问" message:@"请在iPhone的“设置-隐私-照片”中选择允许圈里事访问你的手机相册" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController *vc = (UIViewController *)self.imagePickerDelegate;
        [vc presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)showCamera:(UIViewController *)controller{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    ipc.showsCameraControls = YES;
    [controller presentViewController:ipc animated:YES completion:nil];
}

- (void)showImagePickerForUploadProfileImage:(UIViewController *)controller type:(UIImagePickerControllerSourceType)type{
    if ([self hasPermissionAccess]) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = type;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        [controller presentViewController:ipc animated:YES completion:nil];
    }
}
- (void)showPhotoLibrary:(UIViewController *)controller maxImageCount:(NSInteger )count{
    if ([self hasPermissionAccess]) {
        QBImagePickerController *imagePickerController = [QBImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = count;
        imagePickerController.showsNumberOfSelectedAssets = YES;
        imagePickerController.mediaType = QBImagePickerMediaTypeImage;
        imagePickerController.numberOfColumnsInPortrait = 4;
        
        imagePickerController.assetCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded), //最近添加
                                                          @(PHAssetCollectionSubtypeSmartAlbumUserLibrary), // Camera Roll
                                                          @(PHAssetCollectionSubtypeSmartAlbumPanoramas), // Panoramas
                                                          @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                                          @(PHAssetCollectionSubtypeSmartAlbumGeneric),
                                                          @(PHAssetCollectionSubtypeSmartAlbumScreenshots),
                                                          @(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),
                                                          @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                                          @(PHAssetCollectionSubtypeAlbumCloudShared),
                                                          @(PHAssetCollectionSubtypeAlbumSyncedAlbum),
                                                          @(PHAssetCollectionSubtypeAlbumSyncedEvent),
                                                          @(PHAssetCollectionSubtypeAlbumSyncedFaces),
                                                          @(PHAssetCollectionSubtypeAlbumImported),
                                                          @(PHAssetCollectionSubtypeSmartAlbumAllHidden)];
        
        [controller presentViewController:imagePickerController animated:YES completion:NULL];
    }
}

- (void)showPhotoLibrary:(UIViewController *)controller{
    [self showPhotoLibrary:controller maxImageCount:defaultMaxImageSelectionAllowed]; //默认可选取的照片数
}

#pragma QBImagePickerController

- (BOOL)qb_imagePickerController:(QBImagePickerController *)imagePickerController shouldSelectAsset:(PHAsset *)asset{
    if (imagePickerController.numberOfSelectedAsset == imagePickerController.maximumNumberOfSelection) {
        NSString *titleText = [NSString stringWithFormat:@"最多只能选%@张照片哦",@(imagePickerController.maximumNumberOfSelection)];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleText message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [imagePickerController presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    if ([self.imagePickerDelegate isKindOfClass:[UIViewController class]]) {
        [imagePickerController dismissViewControllerAnimated:YES completion:^{
            
            if ([self.imagePickerDelegate respondsToSelector:@selector(didFinishPickingPhAssets:)]) {
                // passing mutable copy prevents crash,
                // see http://stackoverflow.com/questions/16163081/getting-nsarrayi-addobjectsfromarray-unrecognized-selector-sent-to-instan
                [self.imagePickerDelegate didFinishPickingPhAssets:[assets mutableCopy]];
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
            [self.imagePickerDelegate didFinishPickingPhAssets:[NSMutableArray arrayWithObject:capturedImage]];
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

//#define take_photo @"拍照"
//#define choose_album @"从手机相册选择"
//
//- (void)startPickingImageFromLocalSourceFor:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImagePickerDelegate>*)controller{
//    [UIActionSheet showInView:controller.view
//                    withTitle:nil
//            cancelButtonTitle:@"取消"
//       destructiveButtonTitle:nil
//            otherButtonTitles:@[take_photo,choose_album]
//                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
//    {
//        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:take_photo]) {
//            [self showCamera:controller];
//        }
//        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:choose_album]) {
//            [self showPhotoLibrary:controller];
//        }
//    }];
//}

@end

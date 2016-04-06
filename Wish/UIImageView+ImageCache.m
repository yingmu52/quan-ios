//
//  UIImageView+ImageCache.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "UIImageView+ImageCache.h"

@implementation UIImageView (ImageCache)


- (void)downloadImageWithImageId:(NSString *)imageId size:(FetchCenterImageSize)size{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    FetchCenter *fetchCenter = [[FetchCenter alloc] init];
    
    //检查本地是否有更高分辨率的图片存在
    NSURL *originalURL = [fetchCenter urlWithImageID:imageId size:FetchCenterImageSizeOriginal];
    
    if ([manager diskImageExistsForURL:originalURL]) {
        self.image = [manager.imageCache imageFromDiskCacheForKey:[manager cacheKeyForURL:originalURL]];
    }else{
        //图片地址拼接
        NSURL *url = [fetchCenter urlWithImageID:imageId size:size];
        
        //检测本地缓存
        NSString *localKey = [manager cacheKeyForURL:url];
        BOOL isTargetImageExist = [manager diskImageExistsForURL:url];
        
        //下载图片
        if (!isTargetImageExist) {
            [self sd_setImageWithURL:url
                    placeholderImage:nil
                             options:SDWebImageRetryFailed
                           completed:^(UIImage *image,
                                       NSError *error,
                                       SDImageCacheType cacheType,
                                       NSURL *imageURL) {
                               dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                   [manager.imageCache storeImage:image forKey:localKey];
                               });
                               
                           }];
        }else{
            //        NSLog(@"可从本地获取");
            self.image = [manager.imageCache imageFromDiskCacheForKey:localKey];
        }
    }
}


// **** use txydownloader ****
//        TXYDownloader *downloadManager = [[TXYDownloader alloc] initWithPersistenceId:nil
//                                                                                 type:TXYDownloadTypePhoto];
//        [downloadManager download:url.absoluteString
//                           target:self
//                        succBlock:^(NSString *url, NSData *data, NSDictionary *info) {
//                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                //Background Thread
//                                UIImage *image = [UIImage imageWithData:data];
//                                [manager.imageCache storeImage:image forKey:localKey];
//                                dispatch_main_async_safe(^{
//                                    self.image = image;
//                                });
//                            });
//                        }failBlock:^(NSString *url, NSError *error){
//                            NSLog(@"图片下载失败，code:%zd desc:%@", error.code, error.domain);
//                        }progressBlock:^(NSString *url, NSNumber *value){
//                        } param:nil];
@end


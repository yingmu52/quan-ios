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
    
    //图片地址拼接
    NSURL *url = [fetchCenter urlWithImageID:imageId size:size];
    
    //检测本地缓存
    NSString *localKey = [manager cacheKeyForURL:url];
    BOOL isImageExist = [manager diskImageExistsForURL:url];
    
    //请求较大的图片时，如果原图存在时直接设置原图，（主人发图时，原图被缓存下来，可以直接使用）
    if (size >= FetchCenterImageSize400) {
        NSURL *urlOriginal = [fetchCenter urlWithImageID:imageId size:FetchCenterImageSizeOriginal];
        if ([manager diskImageExistsForURL:urlOriginal]) { //本地有原图的缓存
//            NSLog(@"检测到原图");
            self.image = [manager.imageCache imageFromDiskCacheForKey:[manager cacheKeyForURL:urlOriginal]];
            return;
        }
    }
    
    //下载图片
    if (!isImageExist) {
//        NSLog(@"正在下载：%@\n",url);
        [self sd_setImageWithURL:url
                placeholderImage:nil
                         options:SDWebImageContinueInBackground
                       completed:^(UIImage *image,
                                   NSError *error,
                                   SDImageCacheType cacheType,
                                   NSURL *imageURL) {
                           dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               //Background Thread
                               [manager.imageCache storeImage:image forKey:localKey];
                           });
                           
                       }];
    }else{
        NSLog(@"可从本地获取");
        self.image = [manager.imageCache imageFromDiskCacheForKey:localKey];
    }
}

@end


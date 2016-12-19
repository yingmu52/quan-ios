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
    //图片地址拼接
    NSURL *url = [[FetchCenter new] urlWithImageID:imageId size:size];

    [self sd_setImageWithURL:url
                   completed:^(UIImage *image,
                               NSError *error,
                               SDImageCacheType cacheType,
                               NSURL *imageURL)
     {
         if (error) {
             [FetchCenter reportToIssueLog:[NSString stringWithFormat:@"图片下载失败\n %@ \n %@ \n",error,imageURL]];
             
             [FIRAnalytics logEventWithName:@"ImageViewDownloadFailure"
                                 parameters:@{@"error":error.description,
                                              @"url":url.absoluteString,
                                              @"imageURL":imageURL.absoluteString}];
         }
     }];

    /*
    self.image = nil; //重复使用cell时，需要清空图像
    
    if (imageId) {
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
                                 options:SDWebImageAvoidAutoSetImage
                               completed:^(UIImage *image,
                                           NSError *error,
                                           SDImageCacheType cacheType,
                                           NSURL *imageURL) {
                                   if (image && !error) {
                                       self.image = image;
                                   }else{
                                       [FetchCenter reportToIssueLog:[NSString stringWithFormat:@"图片下载失败\n %@ \n %@ \n",error,imageURL]];
                                       [FIRAnalytics logEventWithName:@"Image Download Failure"
                                                           parameters:@{@"error":error,
                                                                        @"url":url,
                                                                        @"imageURL":imageURL}];
                                   }
                               }];
            }else{
                //        NSLog(@"可从本地获取");
                self.image = [manager.imageCache imageFromDiskCacheForKey:localKey];
            }
        }
    }
     */
}

@end


@implementation UIButton (ImageCache)

- (void)downloadImageWithImageId:(NSString *)imageId size:(FetchCenterImageSize)size{
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    //图片地址拼接
    NSURL *url = [[FetchCenter new] urlWithImageID:imageId size:size];
    
    [self sd_setImageWithURL:url forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            [FetchCenter reportToIssueLog:[NSString stringWithFormat:@"图片下载失败\n %@ \n %@ \n",error,imageURL]];
            [FIRAnalytics logEventWithName:@"ButtonImageViewDownloadFailure"
                                parameters:@{@"error":error.description,
                                             @"url":url.absoluteString}];
            NSLog(@"%@",url);
        }
    }];
}

@end



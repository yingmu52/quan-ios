//
//  UIImageView+ImageCache.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "UIImageView+ImageCache.h"

@implementation UIImageView (ImageCache)

- (BOOL)showImageWithImageUrl:(NSURL *)url{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *localKey = [manager cacheKeyForURL:url];
    BOOL isImageExist = [manager diskImageExistsForURL:url];
    if (!isImageExist) {
//        NSLog(@"%@: downloading from internet",self.class);
        [self sd_setImageWithURL:url
                placeholderImage:nil
                         options:SDWebImageCacheMemoryOnly
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
//        NSLog(@"%@: loading locally",self.class);
        self.image = [manager.imageCache imageFromDiskCacheForKey:localKey];
    }
    return isImageExist;
}

@end


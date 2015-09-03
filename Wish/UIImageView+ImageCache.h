//
//  UIImageView+ImageCache.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-03.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchCenter.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

@interface UIImageView (ImageCache)

- (void)showImageWithImageUrl:(NSURL *)url;

@end

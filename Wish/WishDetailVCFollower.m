//
//  WishDetailVCFollower.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCFollower.h"
#import "UIImageView+WebCache.h"
#import "FetchCenter.h"
#import "Feed.h"
@implementation WishDetailVCFollower


- (WishDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = (WishDetailCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (!cell.feed.image) {
        [cell.photoView sd_setImageWithURL:[[FetchCenter new] urlWithImageID:cell.feed.imageId]
                          placeholderImage:[UIImage imageNamed:@"snow.jpg"]
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
             cell.feed.image = image;
//             NSLog(@"cached");
         }];
    }else{
//        NSLog(@"loaded from feed");
    }
    return cell;
}
@end

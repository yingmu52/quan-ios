//
//  WishDetailVCDiscovery.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-06.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCDiscovery.h"
#import "UIImageView+WebCache.h"
#import "FetchCenter.h"
#import "Feed.h"

@interface WishDetailVCDiscovery () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;

@end
@implementation WishDetailVCDiscovery


- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadFeedFromServer:nil];
}
- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}


- (void)loadFeedFromServer:(NSDictionary *)pageInfo{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    [self.fetchCenter loadFeedsListForPlan:self.plan pageInfo:pageInfo];
}


- (WishDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WishDetailCell *cell = (WishDetailCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (!cell.feed.image) {
        [cell.photoView sd_setImageWithURL:[[FetchCenter new] urlWithImageID:cell.feed.imageId]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     cell.feed.image = image;
                                     //             NSLog(@"cached");
                                 }];
    }else{
        //        NSLog(@"loaded from feed");
    }
    return cell;
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject
{
    dispatch_main_async_safe((^{
        //show alerts
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                    message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
        
        //update navigation item
        self.navigationItem.rightBarButtonItem = nil;
        
    }));

}

- (void)didFinishLoadingFeedList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage{    
    dispatch_main_async_safe(^{
        //update navigation item
        self.navigationItem.rightBarButtonItem = nil;
    })
    

}
@end






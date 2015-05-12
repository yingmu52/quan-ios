//
//  WishDetailVCDiscovery.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-06.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCDiscovery.h"
#import "UIImageView+WebCache.h"
#import "Feed.h"
#import "User.h"
@interface WishDetailVCDiscovery ()
@property (nonatomic) BOOL hasNextPage;
@property (nonatomic,strong) NSDictionary *pageInfo;
@end
@implementation WishDetailVCDiscovery


- (void)viewDidLoad{
    [super viewDidLoad];
//    [self setupBadageImageView]; //display badge
    
    self.hasNextPage = YES; //important, must set before [self loadMore]
    [self loadMore];
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
    //show alerts
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    
    //update navigation item
    self.navigationItem.rightBarButtonItem = nil;

}

- (void)didFinishLoadingFeedList:(NSDictionary *)pageInfo hasNextPage:(BOOL)hasNextPage{
    self.hasNextPage = hasNextPage;
    self.pageInfo = pageInfo;
    [self updateHeaderView];
    //update navigation item
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadMore{
    if (self.hasNextPage) {
        [self loadFeedFromServer:self.pageInfo];
    }else{
        self.title = @"别拉了，没了！";
        [self performSelector:@selector(setTitle:) withObject:nil afterDelay:0.5f];
    }
}


- (void)dealloc{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (Feed *feed in self.fetchedRC.fetchedObjects){
        if (![feed.plan.ownerId isEqualToString:[User uid]]) {
            [delegate.managedObjectContext deleteObject:feed];
        }
    }
    [delegate saveContext];
}

- (NSString *)segueForFeed{
    return @"showDiscoverFeedDetail";
}
@end






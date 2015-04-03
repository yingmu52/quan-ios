//
//  DiscoveryVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-30.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryVCData.h"
#import "FetchCenter.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
@interface DiscoveryVCData () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSMutableArray *plans;
@end

@implementation DiscoveryVCData


- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self discover];
}


- (void)dealloc{
#warning fix this 
    
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    for (Plan *plan in self.plans){ //delete plans from other users
//        if (plan.planId != [User uid]){
//            [delegate.managedObjectContext deleteObject:plan];
//        }
//        
//    }
////    NSLog(@"%@",[[AppDelegate getContext] deletedObjects]);
//    [delegate saveContext];

}
- (void)discover{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    [self.fetchCenter getDiscoveryList];
}


#pragma mark - collection view delegate & data soucce
- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = self.plans[indexPath.section * 4 + indexPath.item];
    cell.discoveryTitleLabel.text = plan.planTitle;
    [cell.discoveryImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:plan.backgroundNum]
                               placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    cell.discoveryFollowerCountLabel.text = [NSString stringWithFormat:@"%@ 关注",plan.followCount];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.plans.count / 4;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}


#pragma mark - fetch center delegate

- (NSMutableArray *)plans{
    if (!_plans) {
        _plans = [[NSMutableArray alloc] init];
    }
    return _plans;
}
- (void)didfinishFetchingDiscovery:(NSArray *)plans{
    [self.plans addObjectsFromArray:plans];
    dispatch_main_async_safe(^{
        [self.collectionView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
    })
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)handleFailure:(NSDictionary *)info{
    dispatch_main_async_safe((^{
        self.navigationItem.rightBarButtonItem = nil;
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                    message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }));
    
}

@end

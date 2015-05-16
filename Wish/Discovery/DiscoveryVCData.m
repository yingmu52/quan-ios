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
#import "WishDetailVCFollower.h"
@interface DiscoveryVCData () <FetchCenterDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) FetchCenter *fetchCenter;
//@property (nonatomic,strong) NSMutableArray *plans;
@property (nonatomic,strong) NSMutableArray *itemChanges;

@end

@implementation DiscoveryVCData

static NSUInteger numberOfitems = 4.0; //float is important

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

- (void)addWish{
    [self performSegueWithIdentifier:@"showPostViewFromDiscovery" sender:nil];
}
//- (void)dealloc{
//    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    for (Plan *plan in self.plans){ //delete plans from other users
//        if (![plan.ownerId isEqualToString:[User uid]]){
//            [delegate.managedObjectContext deleteObject:plan];
//        }
//    }
////    NSLog(@"%@",[[AppDelegate getContext] deletedObjects]);
//    [delegate saveContext];
//}
- (void)discover{
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
//    [spinner startAnimating];
    [self.fetchCenter getDiscoveryList];
}


#pragma mark - collection view delegate & data soucce
- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = indexPath.section * 4 + indexPath.item;
    
    Plan *plan = [self.fetchedRC.fetchedObjects objectAtIndex:index];

    [cell.discoveryImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:plan.backgroundNum]
                               placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.discoveryTitleLabel.text = plan.planTitle;
    cell.discoveryByUserLabel.text = [NSString stringWithFormat:@"by %@",plan.owner.ownerName];
    cell.discoveryFollowerCountLabel.text = [NSString stringWithFormat:@"%@ 关注",plan.followCount];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return round(((float)self.fetchedRC.fetchedObjects.count) / numberOfitems);;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section != round(((float)self.fetchedRC.fetchedObjects.count) / numberOfitems) - 1){
        return numberOfitems;
    }else{
        return self.fetchedRC.fetchedObjects.count % numberOfitems;
    }
}


#pragma mark - fetch center delegate

//- (NSMutableArray *)plans{
//    if (!_plans) {
//        _plans = [[NSMutableArray alloc] init];
//    }
//    return _plans;
//}
- (void)didfinishFetchingDiscovery:(NSArray *)plans{
//    [self.plans addObjectsFromArray:plans];
//    [self.collectionView reloadData];
//    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)handleFailure:(NSDictionary *)info{
//    self.navigationItem.rightBarButtonItem = nil;
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = indexPath.section * numberOfitems + indexPath.item;
    Plan *plan = [self.fetchedRC.fetchedObjects objectAtIndex:index];
    [self performSegueWithIdentifier:@"showDiscoveryWishDetail" sender:plan];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"]){
        [segue.destinationViewController setPlan:sender];
    }
}

#pragma mark - fetched results controller delegate
- (NSFetchedResultsController *)fetchedRC
{
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }else{
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        //        request.predicate = [NSPredicate predicateWithFormat:@"ownerId != %@ && isFollowed == %@",[User uid],@(YES)];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
        [request setFetchBatchSize:3];
        //create FetchedResultsController with context, sectionNameKeyPath, and you can cache here, so the next work if the same you can use your cashe file.
        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:context
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        _fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        [_fetchedRC performFetch:nil];
        return _fetchedRC;
    }
}


@end




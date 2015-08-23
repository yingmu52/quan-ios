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
@property (nonatomic,strong) NSMutableArray *itemChanges;
@property (nonatomic,strong) NSBlockOperation *blockOperation;
@property (nonatomic,strong) UIButton *addButton;
@property (nonatomic) CGFloat lastContentOffSet;
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
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self loaddAddButton];
    [self.fetchCenter getDiscoveryList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.addButton removeFromSuperview];
}
- (void)addWish{
    [self performSegueWithIdentifier:@"showPostViewFromDiscovery" sender:nil];
}

- (void)dealloc{
    self.fetchedRC.delegate = nil;
    [self removePlans];
}

- (void)removePlans{
    NSUInteger numberOfPreservingPlans = 100;
    NSArray *allPlans = self.fetchedRC.fetchedObjects;
    if (allPlans.count > numberOfPreservingPlans) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        for (NSInteger i = numberOfPreservingPlans ;i < self.fetchedRC.fetchedObjects.count; i ++){
            Plan *plan = self.fetchedRC.fetchedObjects[i];
            if ([plan isDeletable]){
                NSLog(@"Discovery: removing plan %@",plan.planId);
                [delegate.managedObjectContext deleteObject:plan];
            }
        }
        [delegate saveContext];
    }
}

#pragma mark - collection view delegate & data soucce

- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    [cell.discoveryImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:plan.backgroundNum]];
    cell.discoveryTitleLabel.text = plan.planTitle;
    cell.discoveryByUserLabel.text = [NSString stringWithFormat:@"by %@",plan.owner.ownerName];
    cell.discoveryFollowerCountLabel.text = [NSString stringWithFormat:@"%@ 关注",plan.followCount];

    //显示置顶的角标
    if ([plan.cornerMask isEqualToString:@"top"]){
        cell.cornerMask.image = [Theme topImageMask];
    }else{
        cell.cornerMask.image = nil;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}

#pragma mark - fetch center delegate


- (void)didfinishFetchingDiscovery:(NSArray *)plans{
    
    //删除在本地缓存的不存在于服务器上的事件，异线。
    dispatch_queue_t compareList = dispatch_queue_create("DiscoveryVCData.compareList", NULL);
    dispatch_async(compareList, ^{
        for (Plan *plan in self.fetchedRC.fetchedObjects){
            if (![plans containsObject:plan]){
                [[AppDelegate getContext] deleteObject:plan];
                NSLog(@"Removing plan %@ : %@",plan.planId,plan.planTitle);
            }
        }
    });
}

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [self handleFailure:info];
}

- (void)handleFailure:(NSDictionary *)info{
//    self.navigationItem.rightBarButtonItem = nil;
//    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
//                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
//                               delegate:self
//                      cancelButtonTitle:@"OK"
//                      otherButtonTitles:nil, nil] show];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // save the plan image background only when user select a certain plan!
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];

    if (!plan.image){
        DiscoveryCell *cell = (DiscoveryCell *)[collectionView cellForItemAtIndexPath:indexPath];
        plan.image = cell.discoveryImageView.image;
    }
    
    if ([plan.owner.ownerId isEqualToString:[User uid]] && ![plan.planStatus isEqualToNumber:@(PlanStatusFinished)]){ //已完成的事件不支持编辑
        [self performSegueWithIdentifier:@"showWishDetailVCOwnerFromDiscovery" sender:plan];
    }else{
        [self performSegueWithIdentifier:@"showDiscoveryWishDetail" sender:plan];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Plan *)plan{
    if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"] || [segue.identifier isEqualToString:@"showWishDetailVCOwnerFromDiscovery"]){
        [segue.destinationViewController setPlan:plan];
    }
    self.navigationController.navigationBar.shadowImage = [UIImage new]; //隐藏导航割线
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - fetched results controller delegate
- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC) {
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"discoverIndex" ascending:YES]];

        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:[AppDelegate getContext]
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        _fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        [_fetchedRC performFetch:nil];
    }
    return _fetchedRC;

}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
        default:
            break;
    }
    [self.itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.collectionView performBatchUpdates: ^{
        for (NSDictionary *change in self.itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                    default:
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        self.itemChanges = nil;;
    }];
    
}

#pragma mark - Scroll view delegate (Add Button Animation)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffSet = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.lastContentOffSet < scrollView.contentOffset.y) {
        //hide camera
        if (self.addButton.isUserInteractionEnabled) [self animateCameraIcon:YES];
        
    }else if (self.lastContentOffSet > scrollView.contentOffset.y) {
        //show camera
        if (!self.addButton.isUserInteractionEnabled) [self animateCameraIcon:NO];
    }
    
}

- (void)animateCameraIcon:(BOOL)shouldHideCamera{
    CGFloat movingDistance = CGRectGetHeight(self.view.frame) * 0.5f;
    self.addButton.userInteractionEnabled = !shouldHideCamera;
    if (shouldHideCamera){
        [UIView animateWithDuration:1.0 animations:^{
            self.addButton.center = CGPointMake(self.addButton.center.x,self.addButton.center.y + movingDistance);
        }];
    }else{
        [UIView animateWithDuration:0.7 animations:^{
            self.addButton.center = CGPointMake(self.addButton.center.x,self.addButton.center.y - movingDistance);
        }];
    }
}
- (void)loaddAddButton{
    //读取加号按扭
    UIImage *icon = [Theme discoveryAddButton];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:icon forState:UIControlStateNormal];
    button.hidden = NO;
    UIWindow *topView = [[UIApplication sharedApplication] keyWindow];
    CGFloat trailing = 15;
    CGFloat bottom = self.tabBarController.tabBar.frame.size.height;
    CGFloat side = 65.0f;
    [button setFrame:CGRectMake(topView.frame.size.width - trailing - side,topView.frame.size.height - bottom - side,side,side)];
    [topView addSubview:button];
    [button addTarget:self action:@selector(addWish) forControlEvents:UIControlEventTouchUpInside];
    self.addButton = button;
}

@end




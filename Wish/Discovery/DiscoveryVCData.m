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
#import "ShuffleViewController.h"
#import "PostFeedViewController.h"
@interface DiscoveryVCData () <FetchCenterDelegate,NSFetchedResultsControllerDelegate,ShuffleViewControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSMutableArray *itemChanges;
@property (nonatomic,strong) NSBlockOperation *blockOperation;
@end

@implementation DiscoveryVCData

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self.fetchCenter getDiscoveryList];
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
    
    NSURL *imageUrl = [self.fetchCenter urlWithImageID:plan.backgroundNum size:FetchCenterImageSize400];
    [cell.discoveryImageView showImageWithImageUrl:imageUrl];

    cell.discoveryTitleLabel.text = plan.planTitle;
    cell.discoveryByUserLabel.text = [NSString stringWithFormat:@"by %@",plan.owner.ownerName];
    cell.discoveryFollowerCountLabel.text = [NSString stringWithFormat:@"%@ 关注",plan.followCount];
    cell.discoveryRecordsLabel.text = [NSString stringWithFormat:@"%@ 记录",plan.tryTimes];
    
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


- (void)didfinishFetchingDiscovery:(NSArray *)plans circleTitle:(NSString *)title{
    //删除在本地缓存的不存在于服务器上的事件，异线。
    if (plans.count > 0){ //判断服务器的列表是否有数据，如果没有的话不要处理本地的事件
        dispatch_queue_t compareList = dispatch_queue_create("DiscoveryVCData.compareList", NULL);
        dispatch_async(compareList, ^{
            @try { //当修改plan的属性时，会引起fetchedObjects的数量改变，引起数组索引超出范围。
                for (Plan *plan in self.fetchedRC.fetchedObjects){
                    if (![plans containsObject:plan]){
                        NSLog(@"Removing plan %@ : %@",plan.planId,plan.planTitle);
                        plan.discoverIndex = nil;
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
        });
    }
    
    //设置导航标题
    self.navigationItem.title = title;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // save the plan image background only when user select a certain plan!
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if ([plan.owner.ownerId isEqualToString:[User uid]] &&
        ![plan.planStatus isEqualToNumber:@(PlanStatusFinished)]){ //已完成的事件不支持编辑
        [self performSegueWithIdentifier:@"showWishDetailVCOwnerFromDiscovery" sender:plan];
    }else{
        [self performSegueWithIdentifier:@"showDiscoveryWishDetail" sender:plan];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if ([segue.identifier isEqualToString:@"showShuffleView"]) {
        ShuffleViewController *svc = segue.destinationViewController;
        svc.svcDelegate = self; //用于使用相机回调函数
    }else{
        if ([segue.identifier isEqualToString:@"showPostDetailFromDiscovery"]) { //相机选取照片之后
            PostFeedViewController *pfvc = segue.destinationViewController;
            NSArray *AssetsAndPlan = sender;
            pfvc.assets = [AssetsAndPlan[0] mutableCopy]; //assets
            pfvc.plan = AssetsAndPlan[1]; //plan
        }
        if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"] || [segue.identifier isEqualToString:@"showWishDetailVCOwnerFromDiscovery"]){
            [segue.destinationViewController setPlan:sender];
        }

        //隐藏导航割线
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        
        self.tabBarController.tabBar.hidden = YES;
    }
    
}

#pragma mark - fetched results controller delegate
- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC) {
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"discoverIndex != nil"];
        
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

#pragma mark - Shuffle View Controller Delegate 

- (void)didFinishSelectingImageAssets:(NSArray *)assets forPlan:(Plan *)plan{
    //asset could be either UIImage or PHAsset
    if (assets && plan) {
        [self performSegueWithIdentifier:@"showPostDetailFromDiscovery" sender:@[assets,plan]];
    }
}

- (void)didPressCreatePlanButton:(ShuffleViewController *)svc{
    [self performSegueWithIdentifier:@"showPostViewFromDiscovery" sender:nil];
}

- (void)showShuffView{
    [self performSegueWithIdentifier:@"showShuffleView" sender:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.collectionView addGestureRecognizer:longPress];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 48,CGRectGetHeight(self.navigationController.navigationBar.frame));
    UIButton *addBtn = [Theme buttonWithImage:[Theme navAddDefault]
                                       target:self
                                     selector:@selector(showShuffView)
                                        frame:frame];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
}


#pragma mark - 长按事件可显示相关信息
- (void)longPressed:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
        NSString *msg = [NSString stringWithFormat:@"用户id:%@\n事件id:%@\n事件名:%@",plan.owner.ownerId,plan.planId,plan.planTitle];
        
        //显示弹出提示窗口
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
@end




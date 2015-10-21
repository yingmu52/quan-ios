//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//
#import "HomeViewController.h"
#import "PostFeedViewController.h"
#import "Theme.h"
#import "HomeCardView.h"
#import "Plan+PlanCRUD.h"
#import "Feed+FeedCRUD.h"
#import "AppDelegate.h"
#import "WishDetailViewController.h"
#import "HomeCardFlowLayout.h"
#import "User.h"
#import "SDWebImageCompat.h"
#import "ImagePicker.h"
#import "ViewForEmptyEvent.h"
#import "UIImageView+ImageCache.h"
#import "ShuffleViewController.h"
#import "NZCircularImageView.h"
#import "UIImageView+ImageCache.h"
#import "StationViewController.h"

const NSUInteger maxCardNum = 10;
@interface HomeViewController ()
<NSFetchedResultsControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate,
HomeCardViewDelegate,
UIActionSheetDelegate,
ImagePickerDelegate,
ViewForEmptyEventDelegate,
ShuffleViewControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,weak) Plan *currentPlan;
@property (nonatomic,strong) NSMutableArray *itemChanges;
@property (nonatomic,weak) ViewForEmptyEvent *guideView;
@property (nonatomic,strong) ImagePicker *imagePicker;
@end
@implementation HomeViewController
- (void)updateNavigationTitle{
    NSArray *plans = self.fetchedRC.fetchedObjects;
    if (plans.count > 0) {
        NSInteger page = self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame);
        self.navigationItem.title = [NSString stringWithFormat:@"%@/%@",@(page + 1),@(plans.count)];
    }else{
        self.navigationItem.title = nil;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.fetchedRC.fetchedObjects.count){
        [self setUpEmptyView];
    }else{
        self.guideView = nil;
        [self updateNavigationTitle];
        
    }
    self.tabBarController.tabBar.hidden = NO;
    [self updateNavigationTitle];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateNavigationTitle];
}
- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId == %@ && planStatus == %d",[User uid],PlanStatusOnGoing];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    NSFetchedResultsController *newFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedRC = newFRC;
    _fetchedRC.delegate = self;
    
    // Perform Fetch
    NSError *error = nil;
    [_fetchedRC performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    return _fetchedRC;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self addLongPressGesture];
    [self.fetchCenter fetchPlanListForOwnerId:[User uid]];
}
- (void)addLongPressGesture{
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lp.delaysTouchesBegan = YES;
    lp.minimumPressDuration = 0.3;
    [self.collectionView addGestureRecognizer:lp];
}
- (void)setUpNavigationItem
{
    //1.左上角个人头像图标
    NZCircularImageView *myIcon = [[NZCircularImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    myIcon.backgroundColor = [UIColor lightGrayColor];
    NSString *newPicId = [User updatedProfilePictureId];
    myIcon.userInteractionEnabled = YES;
    myIcon.gestureRecognizers = @[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfileView)]];
    if (newPicId){
        [myIcon showImageWithImageUrl:[self.fetchCenter urlWithImageID:newPicId size:FetchCenterImageSize100]];
    }else{
        myIcon.image = [Theme menuLoginDefault];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myIcon];
    
    //2.右上角加号浮层入口
    UIButton *addBtn = [Theme buttonWithImage:[Theme navAddDefault]
                                       target:self
                                     selector:@selector(showShuffView)
                                        frame:CGRectMake(0,0, 48,CGRectGetHeight(self.navigationController.navigationBar.frame))];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
}

- (void)showProfileView{
    [self performSegueWithIdentifier:@"showMyPageFromHome" sender:nil];
}

- (void)showShuffView{
    [self performSegueWithIdentifier:@"showShuffViewFromHome" sender:nil];
}

- (void)addWish{
    [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
    self.tabBarController.tabBar.hidden = YES;
}


#pragma mark - image picker
- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}
- (void)didPressCameraOnCard:(HomeCardView *)cardView{
    if (self.fetchedRC.fetchedObjects.count) {
        self.currentPlan = [self.fetchedRC objectAtIndexPath:[self.collectionView indexPathForCell:cardView]];
        [self.imagePicker showPhotoLibrary:self];
    }
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    [self performSegueWithIdentifier:@"ShowPostFeedFromHome" sender:@[assets,self.currentPlan]];
}
#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
        [segue.destinationViewController setPlan:sender];
        self.tabBarController.tabBar.hidden = YES;
    }
    if ([segue.identifier isEqualToString:@"ShowPostFeedFromHome"]) {
        PostFeedViewController *pfvc = segue.destinationViewController;
        NSArray *array = sender;
        pfvc.assets = array.firstObject;
        pfvc.plan = array.lastObject;
//        pfvc.plan = self.currentPlan;
//        pfvc.assets = sender;
        self.tabBarController.tabBar.hidden = YES;
    }
    if ([segue.identifier isEqualToString:@"showShuffViewFromHome"]) {
        ShuffleViewController *svc = segue.destinationViewController;
        svc.svcDelegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showStationView"]) {
        StationViewController *svc = segue.destinationViewController;
        NSArray *obj = (NSArray *)sender;
        svc.plan = obj.firstObject;
        svc.longPress = obj.lastObject;
    }
    
}

#pragma mark - 加号浮层回调函数

- (void)didFinishSelectingImageAssets:(NSArray *)assets forPlan:(Plan *)plan{
    //asset could be either UIImage or PHAsset
    if (assets && plan) {
        [self performSegueWithIdentifier:@"ShowPostFeedFromHome" sender:@[assets,plan]];
    }
}

- (void)didPressCreatePlanButton:(ShuffleViewController *)svc{
    [self addWish];
}

#pragma mark -  UICollectionView methods
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    if (plan) {
        if (longPress.state == UIGestureRecognizerStateBegan) {
            [self performSegueWithIdentifier:@"showStationView" sender:@[plan,longPress]];
        }
    }
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:plan];
}
#pragma mark - FetchedResultsController
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
    
    if (!controller.fetchedObjects.count){
        [self setUpEmptyView];
    }else{
        self.collectionView.hidden = NO;
        if (self.guideView){
            [self.guideView removeFromSuperview];
        }
    }
    
    [self.collectionView performBatchUpdates: ^{
        for (NSDictionary *change in self.itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        NSLog(@"Home Card: Inserted Plan");
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        NSLog(@"Home Card: Deleted Plan");
                        break;
                    case NSFetchedResultsChangeUpdate:{
                        Plan *plan = [controller objectAtIndexPath:obj];
                        if (plan.planId && plan.backgroundNum) {
                            [UIView performWithoutAnimation:^{
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                [self.collectionView scrollToItemAtIndexPath:obj
                                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                                    animated:NO];
                            }];
                            NSLog(@"Home Card: Updated Plan");
                        }
                    }
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
        // self.title = [NSString stringWithFormat:@"%@ plans",@(self.fetchedRC.fetchedObjects.count)];
        self.itemChanges = nil;
        [self updateNavigationTitle];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }];
}
#pragma mark - implement parent class abstract methods
- (void)configureCollectionViewCell:(HomeCardView *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    NSURL *imageUrl = [self.fetchCenter urlWithImageID:plan.backgroundNum size:FetchCenterImageSize800];
    [cell.imageView showImageWithImageUrl:imageUrl];
    cell.titleLabel.text = plan.planTitle;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@条记录  %@人关注",plan.tryTimes,plan.followCount];
    cell.delegate = self;
    [cell layoutIfNeeded]; //fixed auto layout error on iphone 5s or above
}
#pragma mark - Handling 0 Events Situation
- (void)setUpEmptyView{
    self.collectionView.hidden = YES;
    [self.view addSubview:self.guideView];
}
- (ViewForEmptyEvent *)guideView{
    if (!_guideView){
        //        CGFloat width = 568.0/640 * CGRectGetWidth(self.view.frame);
        //        CGFloat height = 590.0/1136 * CGRectGetHeight(self.view.frame);
        CGFloat leftMargin = 30.0f/640 * CGRectGetWidth(self.view.frame);
        CGFloat width = CGRectGetWidth(self.view.frame) - leftMargin * 2;
        CGFloat height = 590.0 *width / 568;
        CGRect rect = CGRectMake(leftMargin,13,width,height); //13 is angle height, see ViewForEmptyEvent.xib
        _guideView = [ViewForEmptyEvent instantiateFromNib:rect];
        _guideView.delegate = self;
    }
    return _guideView;
}
- (void)didPressButton:(ViewForEmptyEvent *)view{
    [view removeFromSuperview];
    [self addWish];
}
@end

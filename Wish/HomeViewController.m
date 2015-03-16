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
#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "HomeCardView.h"
#import "Plan+PlanCRUD.h"
#import "Feed+FeedCRUD.h"
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "WishDetailViewController.h"
#import "HomeCardFlowLayout.h"
#import "StationView.h"
#import "PopupView.h"
const NSUInteger maxCardNum = 10;

@interface HomeViewController () <NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,PopupViewDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView *cardCollectionView;
@property (nonatomic,weak) Plan *currentPlan;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) StationView *stationView;


@property (nonatomic,strong) NSMutableArray *itemChanges;


@end

@implementation HomeViewController



- (Plan *)currentPlan{
    CGPoint currentPoint = CGPointMake(self.cardCollectionView.center.x + self.cardCollectionView.contentOffset.x,
                                       self.cardCollectionView.center.y + self.cardCollectionView.contentOffset.y);
    NSIndexPath *indexPath = [self.cardCollectionView indexPathForItemAtPoint:currentPoint];
    return [self.fetchedRC objectAtIndexPath:indexPath];
}

- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    request.predicate = [NSPredicate predicateWithFormat:@"userDeleted == %@ && ownerId == %@ && planStatus == %d",@(NO),[SystemUtil getOwnerId],PlanStatusOnGoing];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];

    NSFetchedResultsController *newFRC =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
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
    [self setupCollectionView];

}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self.slidingViewController
                                      selector:@selector(anchorTopViewToRightAnimated:)
                                         frame:frame];
    UIButton *addBtn = [Theme buttonWithImage:[Theme navAddDefault]
                                       target:self
                                     selector:@selector(addWish)
                                        frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];

}


#pragma mark - db operation


#warning - give up for hacking max plan count
- (void)addWish{
    if (self.fetchedRC.fetchedObjects.count > maxCardNum){
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"Life is too short for too many goddamn plans"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }else{
        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
    }
}


#pragma mark - Home Card View Delegate



- (StationView *)stationView
{
    if (!_stationView){
        _stationView = [StationView instantiateFromNib:self.view.frame];
    }
    return _stationView;
}

- (void)popupViewDidPressConfirm:(PopupView *)popupView
{
    if (self.stationView){
        if (self.stationView.selection == StationViewSelectionFinish){
            [popupView.plan updatePlanStatus:PlanStatusFinished];
        }else if (self.stationView.selection == StationViewSelectionGiveUp){
            [popupView.plan updatePlanStatus:PlanStatusGiveTheFuckingUp];
        }else if (self.stationView.selection == StationViewSelectionDelete){
            [popupView.plan deleteSelf];
        }
    }
    [self popupViewDidPressCancel:popupView];
}

- (void)popupViewDidPressCancel:(PopupView *)popupView
{
    [popupView removeFromSuperview];
    [self.stationView removeFromSuperview];
    self.stationView = nil;

}

#pragma mark - Camera Util

- (IBAction)showCamera:(UIButton *)sender{
    if (self.fetchedRC.fetchedObjects.count) {
        UIImagePickerController *controller = [SystemUtil showCamera:self];
        if (controller) {
            [self presentViewController:controller
                               animated:YES
                             completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        UIImage *capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
//        Feed *feed = [Feed createFeedWithImage:capturedImage inPlan:self.currentPlan];
        //NSLog(@"%@",NSStringFromCGSize(editedImage.size));
        [self performSegueWithIdentifier:@"ShowPostFeedFromHome" sender:capturedImage];
    }];
}


#pragma mark -


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
        [segue.destinationViewController setPlan:sender];
//        WishDetailViewController *controller = segue.destinationViewController;
//        controller.plan = [self.fetchedRC objectAtIndexPath:[self.cardCollectionView indexPathForCell:sender]];
    }
    if ([segue.identifier isEqualToString:@"ShowPostFeedFromHome"]) {
        [segue.destinationViewController setPlan:self.currentPlan];
        [segue.destinationViewController setImageForFeed:sender];
        
    }
    
    
}

#pragma mark - Scroll View

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//
//    UICollectionViewFlowLayout *layout = [self cardFlowLayout];
//    
//    CGFloat pageWidth = layout.itemSize.width + layout.minimumLineSpacing; // width + space
//    
//    CGFloat currentOffset = scrollView.contentOffset.x;
//    CGFloat targetOffset = targetContentOffset->x;
//    CGFloat newTargetOffset = 0;
//    
//    if (targetOffset > currentOffset)
//        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
//    else
//        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
//    
//    if (newTargetOffset < 0)
//        newTargetOffset = 0;
//    else if (newTargetOffset > scrollView.contentSize.width)
//        newTargetOffset = scrollView.contentSize.width;
//
//    
//    targetContentOffset->x = currentOffset;
//    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
//}


#pragma mark -  UICollectionView methods

- (UICollectionViewFlowLayout *)cardFlowLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGSize deviceSize = self.view.frame.size;
    CGFloat interMargin = deviceSize.width * 24.0 / 640;
    CGFloat itemWidth = 548.0/640*deviceSize.width;
    CGFloat itemHeight = 850.0/1136*deviceSize.height;
    CGFloat edgeMargin = deviceSize.width - itemWidth - 2*interMargin;
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    layout.itemSize = CGSizeMake(itemWidth,itemHeight);
    layout.sectionInset = UIEdgeInsetsMake(0, edgeMargin, 0, edgeMargin);
    return layout;
}

-(void)setupCollectionView {
    self.cardCollectionView.backgroundColor = [UIColor clearColor];
    self.cardCollectionView.pagingEnabled = NO;
//    self.cardCollectionView.collectionViewLayout = [self cardFlowLayout];
    self.cardCollectionView.collectionViewLayout = [[HomeCardFlowLayout alloc] init];
    
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lp.delaysTouchesBegan = YES;
    lp.minimumPressDuration = 0.5;
    [self.cardCollectionView addGestureRecognizer:lp];

}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    
    Plan *plan = [self.fetchedRC objectAtIndexPath:[self.cardCollectionView indexPathForItemAtPoint:[longPress locationInView:self.cardCollectionView]]];
    if (plan) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (longPress.state == UIGestureRecognizerStateBegan) {
            self.stationView.plan = plan;
            [keyWindow addSubview:self.stationView];
            [self.stationView layoutIfNeeded]; //important for next line to work
            self.stationView.currentCardLocation = [longPress locationInView:self.stationView];
        }else if (longPress.state == UIGestureRecognizerStateChanged){
            //update card location
            self.stationView.currentCardLocation = [longPress locationInView:self.stationView];
        }else if (longPress.state == UIGestureRecognizerStateEnded ||
                  longPress.state == UIGestureRecognizerStateFailed ||
                  longPress.state == UIGestureRecognizerStateCancelled) {
            //detect selection
            PopupView *popupView;
            //        [self.stationView layoutIfNeeded];
            if (self.stationView.selection == StationViewSelectionFinish){
                popupView = [PopupView showPopupFinishinFrame:keyWindow.frame];
            }else if (self.stationView.selection == StationViewSelectionGiveUp){
                popupView = [PopupView showPopupFailinFrame:keyWindow.frame];
            }else if (self.stationView.selection == StationViewSelectionDelete){
                popupView = [PopupView showPopupDeleteinFrame:keyWindow.frame];
            }
            if (popupView) {
                popupView.delegate = self;
                popupView.plan = self.stationView.plan;
                [keyWindow addSubview:popupView];
            }else{
                [self.stationView removeFromSuperview];
            }
        }

    }

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeCardView *cell = (HomeCardView*)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCardCell" forIndexPath:indexPath];
//    cell.delegate = self;
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    cell.plan = plan;

    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:[self.fetchedRC objectAtIndexPath:indexPath]];
}
#pragma mark - FetchedResultsController
//- (void)controller:(NSFetchedResultsController *)controller
//   didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath
//     forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        switch(type)
//        {
//            case NSFetchedResultsChangeInsert:
//                NSLog(@"Plan inserted");
//                [self.cardCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
//                break;
//                
//            case NSFetchedResultsChangeDelete:
//                NSLog(@"Plan Deleted");
//                [self.cardCollectionView deleteItemsAtIndexPaths:@[indexPath]];
//                break;
//                
//            case NSFetchedResultsChangeUpdate:{
//                HomeCardView *cell = (HomeCardView *)[self.cardCollectionView cellForItemAtIndexPath:indexPath];
//                Plan *oldPlan = cell.plan;
//                Plan *newPlan = [self.fetchedRC objectAtIndexPath:indexPath];
//                if (oldPlan.objectID != newPlan.objectID) {
//                    [self.cardCollectionView reloadItemsAtIndexPaths:@[indexPath]];
//                    NSLog(@"Plan Reloaded");
//                }
//            }
//                break;
//            default:
//                break;
//        }
//    });
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.cardCollectionView reloadData];
//}
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
    }
    [self.itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cardCollectionView performBatchUpdates:^{
            for (NSDictionary *change in self.itemChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:
                            [self.cardCollectionView insertItemsAtIndexPaths:@[obj]];
                            NSLog(@"Inserted Plan");
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.cardCollectionView deleteItemsAtIndexPaths:@[obj]];
                            NSLog(@"Deleted Plan");
                            break;
                        case NSFetchedResultsChangeUpdate:{
                            Plan *plan = [controller objectAtIndexPath:obj];
                            if (plan.planId) {
                                [self.cardCollectionView reloadItemsAtIndexPaths:@[obj]];
                                NSLog(@"Updated Plan");
                            }
                        }
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.cardCollectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
            self.itemChanges = nil;
        }];
    });
}

@end

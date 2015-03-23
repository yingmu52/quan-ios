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
#import "User.h"
const NSUInteger maxCardNum = 10;

@interface HomeViewController ()
<NSFetchedResultsControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate,
PopupViewDelegate,
HomeCardViewDelegate>


@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,weak) Plan *currentPlan;

@property (nonatomic,strong) StationView *stationView;

@property (nonatomic,weak) IBOutlet UIButton *pageButton;

@property (nonatomic,strong) NSMutableArray *itemChanges;

@end

@implementation HomeViewController


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.currentPlan = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updatePage];
}

- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    request.predicate = [NSPredicate predicateWithFormat:@"userDeleted == %@ && ownerId == %@ && planStatus == %d",@(NO),[User uid],PlanStatusOnGoing];
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
    
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lp.delaysTouchesBegan = YES;
    lp.minimumPressDuration = 0.5;
    [self.collectionView addGestureRecognizer:lp];
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
    }else if ([User isUserLogin]){
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
- (void)didPressCameraOnCard:(HomeCardView *)cardView{
    if (self.fetchedRC.fetchedObjects.count) {
        UIImagePickerController *controller = [SystemUtil showCamera:self];
        if (controller) {
            [self presentViewController:controller animated:YES completion:^{
                self.currentPlan = cardView.plan;
            }];
        }
    }

}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        UIImage *capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
        //NSLog(@"%@",NSStringFromCGSize(editedImage.size));
        [self performSegueWithIdentifier:@"ShowPostFeedFromHome" sender:capturedImage];
    }];
}


#pragma mark -


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
        [segue.destinationViewController setPlan:sender];
    }
    if ([segue.identifier isEqualToString:@"ShowPostFeedFromHome"]) {
        [segue.destinationViewController setPlan:self.currentPlan];
        [segue.destinationViewController setImageForFeed:sender];
    }
}
#pragma mark -  UICollectionView methods
- (void)updatePage{
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    [self.pageButton setTitle:[NSString stringWithFormat:@"%@",@(page+1)]
                     forState:UIControlStateNormal];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updatePage];
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    if (plan) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (longPress.state == UIGestureRecognizerStateBegan) {
            [keyWindow addSubview:self.stationView];
            [self.stationView layoutIfNeeded]; //important for next line to work
            self.stationView.currentCardLocation = [longPress locationInView:self.stationView];
            
            self.stationView.plan = plan;
            
            if (!self.stationView.cardImageView.image){
                HomeCardView *cardView = (HomeCardView *)[self.collectionView cellForItemAtIndexPath:indexPath];
                self.stationView.cardImageView.image = cardView.imageView.image;
            }

        }else if (longPress.state == UIGestureRecognizerStateChanged){
            //update card location
            self.stationView.currentCardLocation = [longPress locationInView:self.stationView];
//            NSLog(@"%@",self.stationView.plan.planTitle);
            
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
                [self popupViewDidPressCancel:popupView];
            }
        }

    }

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:[self.fetchedRC objectAtIndexPath:indexPath]];
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
        default:
            break;
    }
    [self.itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView performBatchUpdates:^{
            for (NSDictionary *change in self.itemChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch(type) {
                        case NSFetchedResultsChangeInsert:{
                            [UIView performWithoutAnimation:^{
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            }];
                        }
                            NSLog(@"Inserted Plan");
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            NSLog(@"Deleted Plan");
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
                                NSLog(@"Updated Plan");
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }];
            }
        } completion:^(BOOL finished) {
//            self.title = [NSString stringWithFormat:@"%@ plans",@(self.fetchedRC.fetchedObjects.count)];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
            self.itemChanges = nil;;
            [self updatePage];
        }];
    });
}


#pragma mark - implement parent class abstract methods


- (void)configureCollectionViewCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    HomeCardView *card = (HomeCardView *)cell;
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    card.plan = plan;
    card.delegate = self;

}

@end

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

@interface HomeViewController () <NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HomeCardViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView *cardCollectionView;
@property (nonatomic,weak) Plan *currentPlan;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) StationView *stationView;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.cardCollectionView reloadData];
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

//- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button
//{
//    Plan *plan = [self.fetchedRC objectAtIndexPath:[self.cardCollectionView indexPathForCell:cardView]];
//
//    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
////        [plan deleteSelf];
//        [plan updatePlanStatus:PlanStatusGiveTheFuckingUp];
//    }
//    if ([button.titleLabel.text isEqualToString:@"完成"]) {
//        [plan updatePlanStatus:PlanStatusFinished];
//    }
//    
//}


- (void)didTapOnHomeCardView:(HomeCardView *)cardView
{
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:cardView.plan];
}


- (StationView *)stationView
{
    if (!_stationView){
        _stationView = [StationView instantiateFromNib:self.view.frame];
    }
    return _stationView;
}
- (void)didLongPressedOn:(HomeCardView *)cardView gesture:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.stationView.cardImageView.image = cardView.plan.image;
        [self.navigationController.view addSubview:self.stationView];
        [self.stationView layoutIfNeeded];
        self.stationView.currentCardLocation = [longPress locationInView:self.stationView];

    }else if (longPress.state == UIGestureRecognizerStateChanged){
        //update card and detect selection
        self.stationView.currentCardLocation = [longPress locationInView:self.stationView];
        
    }else if (longPress.state == UIGestureRecognizerStateEnded ||
              longPress.state == UIGestureRecognizerStateFailed ||
              longPress.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"done %@",self.presentingViewController);
        [self.stationView removeFromSuperview];
    }
    
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

#pragma mark -
#pragma mark UICollectionView methods

-(void)setupCollectionView {
    self.cardCollectionView.backgroundColor = [UIColor clearColor];
    self.cardCollectionView.pagingEnabled = NO;
    self.cardCollectionView.collectionViewLayout = [[HomeCardFlowLayout alloc] init];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeCardView *cell = (HomeCardView*)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCardCell" forIndexPath:indexPath];
    cell.delegate = self;
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    cell.plan = plan;

    return cell;
    
}
#pragma mark - FetchedResultsController

//- (void)controller:(NSFetchedResultsController *)controller
//   didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath
//     forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    
//    
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [self.cardCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.cardCollectionView deleteItemsAtIndexPaths:@[indexPath]];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self.cardCollectionView reloadItemsAtIndexPaths:@[indexPath]];
//            break;
//        default:
//            break;
//    }
//}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    [self.cardCollectionView reloadData];
}


@end

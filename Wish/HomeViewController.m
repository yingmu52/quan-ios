//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeViewController.h"

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

const NSUInteger maxCardNum = 10;

@interface HomeViewController () <NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HomeCardViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,weak) IBOutlet UICollectionView *cardCollectionView;
@property (nonatomic,weak) UIImage *capturedImage;
@property (nonatomic,weak) Plan *currentPlan;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;

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

- (void)homeCardView:(HomeCardView *)cardView didPressedButton:(UIButton *)button
{
    Plan *plan = [self.fetchedRC objectAtIndexPath:[self.cardCollectionView indexPathForCell:cardView]];

    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
//        [plan deleteSelf];
        [plan updatePlanStatus:PlanStatusGiveTheFuckingUp];
    }
    if ([button.titleLabel.text isEqualToString:@"完成"]) {
        [plan updatePlanStatus:PlanStatusFinished];
    }
    
}

- (void)didShowMoreView:(UIView *)moreView
{
    self.cardCollectionView.scrollEnabled = NO;
}

- (void)didDismissMoreView:(UIView *)moreView
{
    self.cardCollectionView.scrollEnabled = YES;
}

#pragma mark - Camera Util

- (IBAction)showCamera:(UIButton *)sender{
    UIImagePickerController *controller = [SystemUtil showCamera:self];
    if (controller) {
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        self.capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
        //NSLog(@"%@",NSStringFromCGSize(editedImage.size));
        [self performSegueWithIdentifier:@"ShowPostFeedFromHome" sender:nil];
    }];
}


#pragma mark -

- (void)didTapOnHomeCardView:(HomeCardView *)cardView
{
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:cardView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
        WishDetailViewController *controller = segue.destinationViewController;
        controller.plan = [self.fetchedRC objectAtIndexPath:[self.cardCollectionView indexPathForCell:sender]];
    }
//    if ([segue.identifier isEqualToString:@"ShowPostFeedFromHome"]) {
//
//        PostFeedViewController *pfvc = segue.destinationViewController;
//        
//        pfvc.navigationTitle = self.currentPlan.planTitle;
//        pfvc.previewImage = self.capturedImage;
//        pfvc.delegate = self;
//    }
}

#pragma mark - post feed controller delegate
//- (void)didFinishAddingTitleForFeed:(PostFeedViewController *)postFeedVC{
//    [Feed createFeed:postFeedVC.titleForFeed
//               image:self.capturedImage
//              inPlan:self.currentPlan];
//}
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

//
//  HomeViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-14.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "HomeViewController.h"
#import "UINavigationItem+CustomItem.h"
#import "Theme.h"
#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "HomeCardView.h"
#import "Plan+PlanCRUD.h"
#import "Plan+PlanCRUD.h"
#import "AppDelegate.h"
#import "FetchCenter.h"
#import "WishDetailViewController.h"
#import "MKPagePeekFlowLayout.h"

const NSUInteger maxCardNum = 10;

@interface HomeViewController () <NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HomeCardViewDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView *cardCollectionView;

@property (nonatomic,strong) UIImage *capturedImage;


@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;

@end

@implementation HomeViewController

- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
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
    CGRect frame = CGRectMake(0, 0, 30, 30);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self
                                      selector:@selector(openMenu)
                                         frame:frame];
    
    UIButton *addBtn = [Theme buttonWithImage:[Theme navAddDefault]
                                       target:self
                                     selector:@selector(addWish)
                                        frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    

}

- (void)openMenu{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark - db operation



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
    if ([button.titleLabel.text isEqualToString:@"放弃"]) {
        NSIndexPath *indexPath = [self.cardCollectionView indexPathForCell:cardView];
        Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
        [plan deleteSelf:[AppDelegate getContext]];
    }
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
        self.capturedImage = (UIImage *)info[UIImagePickerControllerEditedImage]; // this line and next line is sequentally important
//        [self performSegueWithIdentifier:@"showPostFromHome" sender:nil];
//        NSLog(@"%@",NSStringFromCGSize(editedImage.size));
    }];
}


#pragma - 

- (void)didTapOnHomeCardView:(HomeCardView *)cardView
{
    [self performSegueWithIdentifier:@"showPlanDetailFromHome" sender:cardView];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlanDetailFromHome"]) {
        WishDetailViewController *controller = segue.destinationViewController;
        controller.plan = [self.fetchedRC objectAtIndexPath:[self.cardCollectionView indexPathForCell:sender]];
#warning need to update!
    }
}

#pragma mark -
#pragma mark UICollectionView methods

-(void)setupCollectionView {
    self.cardCollectionView.backgroundColor = [UIColor clearColor];
//    MKPagePeekFlowLayout *layout = [[MKPagePeekFlowLayout alloc] init];
//    [self.cardCollectionView setCollectionViewLayout:layout];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumInteritemSpacing = -5;
    flow.minimumLineSpacing = -5;
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.cardCollectionView.collectionViewLayout = flow;
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


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self pageSize];
}

- (CGSize)pageSize{
    return CGSizeMake(self.view.frame.size.width - 20.0, self.cardCollectionView.frame.size.height);
}


#pragma mark - FetchedResultsController

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.cardCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
//            [self.cardCollectionView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.cardCollectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.cardCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeMove:
            // dont't support move action
            break;
    }
}

//- (void)controllerDidChangeContent:
//(NSFetchedResultsController *)controller
//{
//    [self.cardCollectionView reloadData];
//}


@end

//
//  FollowingCell.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FollowingCell.h"
#import "SystemUtil.h"
#import "AppDelegate.h"
#import "FollowingImageCell.h"
#import "Feed.h"
@import CoreData;
@interface FollowingCell () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *feedBackground;
@property (weak, nonatomic) IBOutlet UIView *headBackground;
@property (nonatomic,weak) NSFetchedResultsController *fetchedRC;
@end
@implementation FollowingCell

#pragma fetched results controller
- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    
    NSAssert(self.plan,@"nil plan for FollowingCell");
    request.predicate = [NSPredicate predicateWithFormat:@"plan = %@",self.plan];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    request.fetchBatchSize = 3;
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.collectionView reloadData];
}

#pragma mark - collection view delegate and data source
-(FollowingImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = FOLLOWINGIMAGECELLID;
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        identifier = FOLLOWINGIMAGECELLLASTID;
    }
    FollowingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    Feed *feed = [self.fetchedRC objectAtIndexPath:indexPath];
    cell.feedImageView.image = feed.image;
    return cell;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchedRC.fetchedObjects.count;
}

#pragma mark - UI

- (void)setCollectionView:(UICollectionView *)collectionView{
    _collectionView = collectionView;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    
}


- (void)setFeedBackground:(UIView *)feedBackground{
    _feedBackground = feedBackground;
    [SystemUtil setupShawdowForView:_feedBackground];
}

- (void)setHeadBackground:(UIView *)headBackground{
    _headBackground = headBackground;
    _headBackground.backgroundColor = [UIColor whiteColor];
    [SystemUtil setupShawdowForView:_headBackground];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat side = collectionView.bounds.size.height;
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        return CGSizeMake(side*190.0/350, side);
    }
    return CGSizeMake(side,side);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    CGFloat margin = self.collectionView.frame.size.width*14.0/610.0;
    return UIEdgeInsetsMake(0, margin, 0, margin);
}



@end

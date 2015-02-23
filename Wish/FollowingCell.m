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
@import CoreData;
@interface FollowingCell () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *feedBackground;
@property (weak, nonatomic) IBOutlet UIView *headBackground;
@property (nonatomic,weak) NSFetchedResultsController *fetchedRC;
@end
@implementation FollowingCell

- (NSFetchedResultsController *)fetchedRC
{
    NSManagedObjectContext *context = [AppDelegate getContext];
    if (_fetchedRC != nil) {
        return _fetchedRC;
    }
    //do fetchrequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    
    NSAssert(self.plan,@"nil plan for FollowingCell");
    request.predicate = [NSPredicate predicateWithFormat:@"plan = %@",self.plan];
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


-(FollowingImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = FOLLOWINGIMAGECELLID;
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        identifier = FOLLOWINGIMAGECELLLASTID;
    }
    FollowingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    return cell;
    
}

#pragma mark - UI
#pragma uicollectionview delegate and data source

- (void)setWishDetailCollectionView:(UICollectionView *)wishDetailCollectionView{
    _wishDetailCollectionView = wishDetailCollectionView;
    _wishDetailCollectionView.backgroundColor = [UIColor clearColor];
    _wishDetailCollectionView.dataSource = self;
    _wishDetailCollectionView.delegate = self;
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
    CGFloat margin = self.wishDetailCollectionView.frame.size.width*14.0/610.0;
    return UIEdgeInsetsMake(0, margin, 0, margin);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 4;
}

@end

//
//  ShuffleViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ShuffleViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "PreviewCell.h"
#import "SystemUtil.h"
#import "ImagePicker.h"
#import "UIImageView+ImageCache.h"
#import "PostFeedViewController.h"
@import CoreData;
@interface ShuffleViewController () <UICollectionViewDelegateFlowLayout,ImagePickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) ImagePicker *imagePicker;
@end

@implementation ShuffleViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadNewData];
    self.collectionView.mj_header = nil;
    self.collectionView.mj_footer = nil;
}


- (void)loadNewData{
    NSArray *localList = [self.collectionFetchedRC.fetchedObjects valueForKey:@"mUID"];
    [self.fetchCenter getPlanListForOwnerId:[User uid]
                                  localList:localList
                                 completion:nil];
}



- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    //支持点击背影关闭退出浮层
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSFetchRequest *)collectionFetchRequest{
    if (!_collectionFetchRequest) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        request.predicate = [NSPredicate predicateWithFormat:@"owner.mUID == %@ && planStatus == %d",[User uid],PlanStatusOnGoing];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
        _collectionFetchRequest = request;
    }
    return _collectionFetchRequest;
}

- (PreviewCell *)collectionView:(UICollectionView *)aCollectionView
          cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PreviewCell *cell;
    if (indexPath.row != self.collectionFetchedRC.fetchedObjects.count) { //is not the last row
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:PREVIEWCELLNORMAL forIndexPath:indexPath];
        Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
        
        [cell.planImageView downloadImageWithImageId:plan.mCoverImageId size:FetchCenterImageSize400];
        
        cell.titleLabel.text = plan.mTitle;
        cell.recordCountLabel.text = [NSString stringWithFormat:@"%@个记录",plan.tryTimes];
        [cell layoutIfNeeded]; //fixed auto layout error on iphone 5s or above
    }else{
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell_Add" forIndexPath:indexPath];

    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    return self.collectionFetchedRC.fetchedObjects.count + 1; //including the last button
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPat{
    return CGSizeMake(102.0f, 102.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 28.0f, 0, 28.0f);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //场景：1个事件，+号在最后面，此时事件数>0，+号的索引为1
    if (self.collectionFetchedRC.fetchedObjects.count > 0 &&
        indexPath.row != self.collectionFetchedRC.fetchedObjects.count) {
            [self.imagePicker showPhotoLibrary:self];
    }else{
            [self performSegueWithIdentifier:@"showPostViewFromShuffleView" sender:nil];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [super controllerDidChangeContent:controller];
    
    //展示最左边第一项
    [UIView animateWithDuration:0.5 animations:^{
        NSIndexPath *selectedPath = self.collectionView.indexPathsForSelectedItems.lastObject;
        [self.collectionView deselectItemAtIndexPath:selectedPath
                                            animated:YES];
        [self.collectionView setContentOffset:CGPointZero
                                     animated:YES];
    }];
    
}

#pragma mark - image picker
- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    //get select plan
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:[self.collectionView indexPathsForSelectedItems].lastObject];
    [self performSegueWithIdentifier:@"showPostFeedViewFromShuffleView" sender:@[assets,plan]];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showPostFeedViewFromShuffleView"]) {
        PostFeedViewController *pfvc = segue.destinationViewController;
        pfvc.assets = [sender firstObject];
        pfvc.plan = [sender lastObject];
    }
    self.navigationController.navigationBar.hidden = NO;
}
@end



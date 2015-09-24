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

@import CoreData;
@interface ShuffleViewController () <NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout,ImagePickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *itemChanges;
//@property (nonatomic,weak) IBOutlet UILabel *countLabel;
//@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) ImagePicker *imagePicker;
@end

@implementation ShuffleViewController


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    //支持点击背影关闭退出浮层
    [self dismissViewControllerAnimated:YES completion:^{
        ((DiscoveryVCData*)self.svcDelegate).addButton.hidden = NO;
    }];
}

- (IBAction)tapOnPhotoLibraryButton:(UIButton *)sender{
    [self.imagePicker showPhotoLibrary:self];
}

- (IBAction)tapOnCameraButton:(UIButton *)sender{
    [self.imagePicker showCamera:self];
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
    
    _fetchedRC = newFRC;
    // Perform Fetch
    NSError *error = nil;
    [_fetchedRC performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    return _fetchedRC;
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.fetchedRC.fetchedObjects.count > 0) {
        //初始化时选择第一个事件
        NSIndexPath *initialSelectionPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionView selectItemAtIndexPath:initialSelectionPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:initialSelectionPath];

    }
}


- (PreviewCell *)collectionView:(UICollectionView *)aCollectionView
          cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PreviewCell *cell;
    if (indexPath.row != self.fetchedRC.fetchedObjects.count) { //is not the last row
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:PREVIEWCELLNORMAL forIndexPath:indexPath];
        Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
        
        NSURL *imageUrl = [[FetchCenter new] urlWithImageID:plan.backgroundNum size:FetchCenterImageSize400];
        [cell.planImageView showImageWithImageUrl:imageUrl];
        
        cell.titleLabel.text = plan.planTitle;
        cell.recordCountLabel.text = [NSString stringWithFormat:@"%@个记录",plan.tryTimes];
        [cell layoutIfNeeded]; //fixed auto layout error on iphone 5s or above
    }else{
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell_Add" forIndexPath:indexPath];

    }
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count + 1; //including the last button
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

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.fetchedRC.fetchedObjects.count) { //is not the last row

        if (self.fetchedRC.fetchedObjects.count > 1) { //除了最后一个cell, 当事件数为空是会闪退
//            self.countLabel.text = [NSString stringWithFormat:@"%@/%@",@(indexPath.row + 1),@(self.fetchedRC.fetchedObjects.count)];
            //将卡片滚到与三角号对齐
            [collectionView scrollToItemAtIndexPath:indexPath
                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                           animated:YES];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            [self.svcDelegate didPressCreatePlanButton:self];
        }];
    }
}


#pragma mark - image picker
- (ImagePicker *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[ImagePicker alloc] init];
        _imagePicker.imagePickerDelegate = self;
    }
    return _imagePicker;
}

- (void)didFinishPickingPhAssets:(NSArray *)assets{
    //get select plan
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
    [self.svcDelegate didFinishSelectingImageAssets:assets forPlan:plan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end



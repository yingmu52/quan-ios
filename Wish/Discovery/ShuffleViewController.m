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
@import CoreData;
@interface ShuffleViewController () <NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout,ImagePickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *itemChanges;
@property (nonatomic,weak) IBOutlet UILabel *countLabel;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@property (nonatomic,strong) ImagePicker *imagePicker;
@end

@implementation ShuffleViewController


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    //支持点击背影关闭退出浮层
    [self dismissViewControllerAnimated:YES completion:^{
//        self.addButton.hidden = NO;
    }];
}

- (IBAction)tapOnPhotoLibraryButton:(UIButton *)sender{
    [self.imagePicker showCameraOn:self type:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)tapOnCameraButton:(UIButton *)sender{
    [self.imagePicker showCameraOn:self type:UIImagePickerControllerSourceTypeCamera];
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0]; //初始值
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (PreviewCell *)collectionView:(UICollectionView *)aCollectionView
          cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PreviewCell *cell;
    if (indexPath.row != self.fetchedRC.fetchedObjects.count) { //is not the last row
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:PREVIEWCELLNORMAL forIndexPath:indexPath];
        Plan *plan = [self.fetchedRC objectAtIndexPath:indexPath];
        cell.planImageView.image = plan.image;
        cell.titleLabel.text = plan.planTitle;
        cell.recordCountLabel.text = [NSString stringWithFormat:@"%@个记录",plan.tryTimes];
        [cell layoutIfNeeded]; //fixed auto layout error on iphone 5s or above
    }else{
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell_Add" forIndexPath:indexPath];
        cell.layer.borderColor = [SystemUtil colorFromHexString:@"#00C1A8"].CGColor;
        cell.layer.borderWidth = 1.0f;
        
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
    if (indexPath.row != self.fetchedRC.fetchedObjects.count) { //is not the last row
        PreviewCell *cell = (PreviewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell showNormalState];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.fetchedRC.fetchedObjects.count) { //is not the last row
        self.selectedIndexPath = indexPath;
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            [self.svcDelegate didPressCreatePlanButton:self];
        }];
    }
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath{
    _selectedIndexPath = selectedIndexPath;
    PreviewCell *cell = (PreviewCell *)[self.collectionView cellForItemAtIndexPath:_selectedIndexPath];
    if (self.fetchedRC.fetchedObjects.count > 1) { //除了最后一个cell, 当事件数为空是会闪退
        [cell showHeightlightedState];
        self.countLabel.text = [NSString stringWithFormat:@"%@/%@",@(_selectedIndexPath.row + 1),@(self.fetchedRC.fetchedObjects.count)];
        //将卡片滚到与三角号对齐
        [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
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
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        self.itemChanges = nil;
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

- (void)didFinishPickingImage:(UIImage *)image{
    Plan *plan = [self.fetchedRC objectAtIndexPath:self.selectedIndexPath];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.svcDelegate didFinishSelectingImage:image forPlan:plan];
    }];
    
}

@end



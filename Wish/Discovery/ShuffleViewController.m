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
@interface ShuffleViewController () <UICollectionViewDelegateFlowLayout,ImagePickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) ImagePicker *imagePicker;
@end

@implementation ShuffleViewController


- (IBAction)tapOnBackground:(UITapGestureRecognizer *)tap{
    //支持点击背影关闭退出浮层
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSFetchRequest *)collectionFetchRequest{
    if (!_collectionFetchRequest) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        request.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId == %@ && planStatus == %d",[User uid],PlanStatusOnGoing];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
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
        
        [cell.planImageView downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize400];
        
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
    if (self.collectionFetchedRC.fetchedObjects.count > 0 &&
        indexPath.row != self.collectionFetchedRC.fetchedObjects.count) { //场景：1个事件，+号在最后面，此时事件数>0，+号的索引为1
            //将卡片滚到与三角号对齐
            [collectionView scrollToItemAtIndexPath:indexPath
                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                           animated:YES];
            [self.imagePicker showPhotoLibrary:self];
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

- (void)didFinishPickingPhAssets:(NSMutableArray *)assets{
    //get select plan
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:[self.collectionView indexPathsForSelectedItems].lastObject];
    [self.svcDelegate didFinishSelectingImageAssets:assets forPlan:plan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end



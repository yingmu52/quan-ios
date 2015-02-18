//
//  DiscoveryViewController.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-17.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "Theme.h"
#import "UIViewController+ECSlidingViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
@interface DiscoveryViewController () <CHTCollectionViewDelegateWaterfallLayout>

@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self setupWaterFallCollectionView];
}

- (void)setupWaterFallCollectionView{
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = 550/1136*self.collectionView.frame.size.height;
    layout.minimumColumnSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    
    self.collectionView.collectionViewLayout = layout;
}
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *menuBtn = [Theme buttonWithImage:[Theme navMenuDefault]
                                        target:self.slidingViewController
                                      selector:@selector(anchorTopViewToRightAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
}

#pragma mark <UICollectionViewDataSource>
//DiscoveryCell
//DiscoveryOffcialBanner
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DiscoveryCell" forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"DiscoveryOffcialBanner"
                                                                 forIndexPath:indexPath];
    }
    return reusableView;
}


#pragma mark - CHTCollectionViewDelegateWaterfallLayout
    
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(290.0/640*collectionView.frame.size.width, 480.0/1136*collectionView.frame.size.height);
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

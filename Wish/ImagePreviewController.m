//
//  ImagePreviewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "ImagePreviewController.h"
@interface ImagePreviewController ()
@property (nonatomic) NSInteger currenetPage;

@end

@implementation ImagePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backButton = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                           target:self.navigationController
                                         selector:@selector(popViewControllerAnimated:)
                                            frame:frame];
    UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                          target:self
                                        selector:@selector(deleteCurrentlyShownImage)
                                           frame:frame];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavbarStyle];
    if (self.entryIndexPath) {
        [self.collectionView scrollToItemAtIndexPath:self.entryIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [self updateNavigationTitle];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resetNavbarStyle];
}

- (void)setNavbarStyle{
    NavigationBar *navBar = (NavigationBar *)self.navigationController.navigationBar;
    [navBar setNavigationBarWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85]];
    navBar.barStyle = UIBarStyleBlackTranslucent;
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)resetNavbarStyle{
    NavigationBar *navBar = (NavigationBar *)self.navigationController.navigationBar;
    [navBar setNavigationBarWithColor:[UIColor whiteColor]];
    [navBar showDefaultTextColor];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

#pragma mark - 删除

- (void)deleteCurrentlyShownImage{
    [self.previewImages removeObjectAtIndex:self.currenetPage];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currenetPage inSection:0];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self.delegate didRemoveImageAtIndexPath:indexPath];
    [self updateNavigationTitle];
    if (!self.previewImages.count) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 翻页

- (NSInteger)currenetPage{
    return self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame);
}

- (void)updateNavigationTitle{
    if (self.previewImages.count > 1) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@/%@",@(self.currenetPage + 1),@(self.previewImages.count)];
    }else{
        self.navigationItem.title = nil;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateNavigationTitle];
}

#pragma mark - Collection View Delegate and Datasource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPat{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}


- (ImagePreviewCell *)collectionView:(UICollectionView *)aCollectionView
          cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImagePreviewCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:POSTFEEDIMAGEPREVIEWCELL forIndexPath:indexPath];
    cell.imageView.image = self.previewImages[indexPath.row];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.previewImages.count;
}

@end






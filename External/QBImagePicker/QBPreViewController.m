//
//  QBPreViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-18.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "QBPreViewController.h"
#import "Theme.h"
#import "NavigationBar.h"
@import Photos;
@interface QBPreViewController ()
@property (nonatomic,strong) UIButton *checkMarkButton;
@end

@implementation QBPreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.checkMarkButton = [Theme buttonWithImage:[Theme checkmarkUnSelected]
                                           target:self
                                         selector:@selector(tapOnCheckMarkButton)
                                            frame:CGRectMake(0, 0, 25, 25)];
    [self.checkMarkButton setImage:[Theme checkmarkSelected] forState:UIControlStateSelected];
    
    [self.checkMarkButton setSelected:[self.qbDelegate hasAssetBeingSelectedAtIndexPath:self.entryIndexPath]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.checkMarkButton];
    [self setUpToolbarItems];

}


- (void)setUpToolbarItems
{
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80.0, 35.0)];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    button.backgroundColor = [SystemUtil colorFromHexString:@"#51BFA6"];
    button.layer.cornerRadius = 4.0f;
    [button addTarget:self.qbDelegate action:@selector(InQBPreviewDidPressDone) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.toolbarItems = @[space,finishButton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
}

- (void)tapOnCheckMarkButton{
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].lastObject;
    BOOL isCurrentIndexSelected = [self.qbDelegate hasAssetBeingSelectedAtIndexPath:indexPath];
    
    if (isCurrentIndexSelected) {
        [self.qbDelegate performActionForAssetAtIndexPath:indexPath shouldSelect:NO];
        [self.checkMarkButton setSelected:NO];
    }else if ([self.qbDelegate shouldSelectIndexPath:indexPath]){
        [self.qbDelegate performActionForAssetAtIndexPath:indexPath shouldSelect:YES];
        [self.checkMarkButton setSelected:YES];
    }
}
#pragma mark - Collection View Delegate 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.qbDelegate numberOfCell];
}

- (ImagePreviewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImagePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:POSTFEEDIMAGEPREVIEWCELL
                                                                       forIndexPath:indexPath];
    [self.qbDelegate configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.checkMarkButton setSelected:[self.qbDelegate hasAssetBeingSelectedAtIndexPath:indexPath]];
}

@end

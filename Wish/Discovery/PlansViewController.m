//
//  PlansViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-28.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "PlansViewController.h"
#import "CircleSettingViewController.h"
#import "PostViewController.h"
#import "EmptyCircleView.h"

@interface PlansViewController () <EmptyCircleViewDelegate>
@property (nonatomic,strong) EmptyCircleView *emptyView;
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation PlansViewController

- (void)viewWillAppear:(BOOL)animated{
    //don't call super here.
    if (!self.collectionFetchedRC.fetchedObjects.count) {
        [self setUpEmptyView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"showCircleSettingView"]) {
        CircleSettingViewController *csc = segue.destinationViewController;
        //        csc.delegate = self;
        csc.circle = self.circle;
    }
    if ([segue.identifier isEqualToString:@"showPostFromPlansView"]) {
        PostViewController *pvc = segue.destinationViewController;
        pvc.circle = self.circle;
    }
}

- (NSFetchRequest *)collectionFetchRequest{
    if (!_collectionFetchRequest) {
        _collectionFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _collectionFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circle == %@",self.circle];
        _collectionFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    }
    return _collectionFetchRequest;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.title = self.circle.circleName;
    
    //只有主人才能设置圈子
    if ([self.circle.ownerId isEqualToString:[User uid]]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navSettingIcon]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(showCircleSettingView)];
    }else{
        //避免非圈主时出现关注页入口
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.navigationItem.title = self.circle.circleName;
    
    
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];
    [self loadMoreData];

}

- (void)loadMoreData{
    NSArray *localList = [self.collectionFetchedRC.fetchedObjects valueForKey:@"planId"];
    [self.fetchCenter getPlanListInCircleId:self.circle.circleId 
                                  localList:localList
                                     onPage:self.currentPage
                                 completion:^(NSNumber *currentPage, NSNumber *totalPage) {
        if ([currentPage isEqualToNumber:totalPage]) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            self.currentPage = @(currentPage.integerValue + 1);
            [self.collectionView.mj_footer endRefreshing];
        }
    }];
}

- (void)showCircleSettingView{
    [self performSegueWithIdentifier:@"showCircleSettingView" sender:nil];
}


#pragma mark - 处理当圈子没有事件的情况

- (void)setUpEmptyView{
    if (!self.collectionFetchedRC.fetchedObjects.count){
        self.collectionView.hidden = YES;
        if (self.circle) {
            [self.emptyView.circleImageView downloadImageWithImageId:self.circle.imageId size:FetchCenterImageSize200];
            self.emptyView.circleTitleLabel.text = self.circle.circleName;
            self.emptyView.circleDescriptionLabel.text = self.circle.circleDescription;
            [self.view addSubview:self.emptyView];
        }
    }else{
        self.collectionView.hidden = NO;
        if ([self.view.subviews containsObject:self.emptyView]) {
            [self.emptyView removeFromSuperview];
        }
    }
}
- (EmptyCircleView *)emptyView{
    if (!_emptyView){
        CGFloat margin = 30.0f/640 * CGRectGetWidth(self.view.frame);
        CGFloat width = CGRectGetWidth(self.view.frame) - margin * 2;
        CGFloat height = 590.0 *width / 568;
        CGRect rect = CGRectMake(margin,100,width,height);
        _emptyView = [EmptyCircleView instantiateFromNib:rect];
        _emptyView.delegate = self;
    }
    return _emptyView;
}

- (void)didPressedButtonOnEmptyCircleView:(EmptyCircleView *)emptyView{
    [self performSegueWithIdentifier:@"showPostFromPlansView" sender:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    if (controller == self.collectionFetchedRC) {
        [super controllerDidChangeContent:controller];
        [self setUpEmptyView];
    }
}

@end

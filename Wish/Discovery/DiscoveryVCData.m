//
//  DiscoveryVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-30.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryVCData.h"
#import "FetchCenter.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
#import "WishDetailVCOwner.h"
@interface DiscoveryVCData () <FetchCenterDelegate>
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation DiscoveryVCData

- (void)viewDidLoad{
    [super viewDidLoad];

    
    //长按显示事件信息，方便开发调试, 目前只支持内网
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_TESTURL]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(longPressed:)];
        [self.collectionView addGestureRecognizer:longPress];
    }
    
    if (!self.circle) { //发现页，self.circle == nil 是圈子事件页
        //设置导航项目
        BOOL isOnTestEnvironment = [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_TESTURL];
        if (isOnTestEnvironment) {
            self.navigationItem.title = [NSString stringWithFormat:@"测试环境 %@",TEST_URL];
        }else{
            self.navigationItem.title = @"圈里事";
        }
        
        //设置关注图标
        UIButton *followButton = [Theme buttonWithImage:[Theme navIconFollowDefault] target:self selector:@selector(showFollowingView) frame:CGRectMake(0, 0, 25, 25)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:followButton];
        
    }
    
    //登陆态无关注入口
    if ([User isVisitor]) {
        self.navigationItem.rightBarButtonItem = nil;
    }

    
}

- (void)loadNewData{
    NSArray *localList = [self.collectionFetchedRC.fetchedObjects valueForKey:@"planId"];
    [self.fetchCenter getDiscoveryList:localList
                                onPage:nil
                            completion:^(NSNumber *currentPage, NSNumber *totalPage)
     {
         self.currentPage = @(2); //这个currentPage其实是下一页的意思
         [self.collectionView.mj_header endRefreshing];
         [self.collectionView.mj_footer endRefreshing];
     }];
}
- (void)loadMoreData{
    NSArray *localList = [self.collectionFetchedRC.fetchedObjects valueForKey:@"planId"];
    [self.fetchCenter getDiscoveryList:localList
                                onPage:self.currentPage
                            completion:^(NSNumber *currentPage, NSNumber *totalPage)
     {
         if ([currentPage isEqualToNumber:totalPage]) {
             [self.collectionView.mj_footer endRefreshingWithNoMoreData];
         }else{
             self.currentPage = @(currentPage.integerValue + 1);
             [self.collectionView.mj_footer endRefreshing];
         }
         
     }];
}


- (void)showFollowingView{
    [self performSegueWithIdentifier:@"showFollowingView" sender:nil];
}


#pragma mark - collection view delegate & data soucce


- (MSCollectionCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSCollectionCell *cell = (MSCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DiscoveryCell" forIndexPath:indexPath];
    cell.ms_shouldHaveBorder = YES;
    
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    [cell.ms_imageView1 downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize400];
    [cell.ms_imageView2 downloadImageWithImageId:plan.owner.headUrl size:FetchCenterImageSize50];
    cell.ms_titleLabel.text = plan.planTitle;
    cell.ms_subTitleLabel.text = [NSString stringWithFormat:@"%@",plan.owner.ownerName];
    cell.ms_infoLabel1.text = [NSString stringWithFormat:@"%@人阅读",plan.readCount];
    
    cell.ms_infoLabel2.text = [NSString stringWithFormat:@"圈子：%@",plan.circle.circleName ? plan.circle.circleName : @""];
    
    //显示置顶的角标
    cell.ms_imageView3.image = [plan.cornerMask isEqualToString:@"top"] ? [Theme topImageMask] : nil;
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // save the plan image background only when user select a certain plan!
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    
    if ([plan.owner.ownerId isEqualToString:[User uid]] &&
        ![plan.planStatus isEqualToNumber:@(PlanStatusFinished)]){ //已完成的事件不支持编辑
        [self performSegueWithIdentifier:@"showWishDetailVCOwnerFromDiscovery" sender:plan];
    }else{
        [self performSegueWithIdentifier:@"showDiscoveryWishDetail" sender:plan];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"] || [segue.identifier isEqualToString:@"showWishDetailVCOwnerFromDiscovery"]){
        [segue.destinationViewController setPlan:sender];
        segue.destinationViewController.hidesBottomBarWhenPushed = YES;
    }
}


- (NSFetchRequest *)collectionFetchRequest{
    if (!_collectionFetchRequest) {
        _collectionFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        //发现页
        _collectionFetchRequest.predicate = [NSPredicate predicateWithFormat:@"discoverIndex >= 888"];
        _collectionFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"discoverIndex" ascending:YES]];
    }
    return _collectionFetchRequest;
}


#pragma mark - 长按事件可显示相关信息
- (void)longPressed:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
        NSString *msg = [NSString stringWithFormat:@"用户id:%@\n事件id:%@\n事件名:%@\n圈名:%@\n圈ID:%@",plan.owner.ownerId,plan.planId,plan.planTitle,plan.circle.circleName,plan.circle.circleId];
        
        //显示弹出提示窗口
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"点击可复制内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //把msg的内容复制到粘帖版上
            [[UIPasteboard generalPasteboard] setString:msg];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

@end




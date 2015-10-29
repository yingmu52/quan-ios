//
//  DiscoveryVCData.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-30.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "DiscoveryVCData.h"
#import "FetchCenter.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageCompat.h"
#import "AppDelegate.h"
#import "User.h"
#import "WishDetailVCFollower.h"
#import "ShuffleViewController.h"
#import "PostFeedViewController.h"
#import "LMDropdownView.h"
@interface DiscoveryVCData () <FetchCenterDelegate,ShuffleViewControllerDelegate,LMDropdownViewDelegate>
@property (nonatomic,strong) LMDropdownView *dropdownView;
@end

@implementation DiscoveryVCData

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //长按显示事件信息，方便开发调试
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(longPressed:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    //设置导航项目
    [self setUpNavigationItem];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([User isSuperUser]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(showCircleList)];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        [self.navigationController.navigationBar addGestureRecognizer:tap];
    }

    [self getDiscoveryList];
    [self.fetchCenter getCircleList:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.gestureRecognizers = nil;
}

- (void)getDiscoveryList{
    [self.fetchCenter getDiscoveryList:^(NSMutableArray *plans, NSString *circleTitle) {
        //设置导航标题
        self.navigationItem.title = circleTitle;
        
        //移除发现页的不存在于服务器上的事件，异线。
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *currentCopy = [self.collectionFetchedRC.fetchedObjects mutableCopy];
            NSPredicate *predicate =[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",plans];
            NSArray *trashPlans = [currentCopy filteredArrayUsingPredicate:predicate]; //a copy of subset of 'currentCopy‘

            dispatch_main_sync_safe(^{
                for (Plan *plan in trashPlans){
                    if (plan.isDeletable) {
                        [plan.managedObjectContext deleteObject:plan];
                    }else{
                        plan.discoverIndex = nil;
                    }
                    NSLog(@"Removing plan %@ : %@",plan.planId,plan.planTitle);
                }
            });
        });
    }];
}

#pragma mark - collection view delegate & data soucce

- (void)configureCell:(DiscoveryCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    [cell.discoveryImageView downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize400];
    cell.discoveryTitleLabel.text = plan.planTitle;
    cell.discoveryByUserLabel.text = [NSString stringWithFormat:@"by %@",plan.owner.ownerName];
    cell.discoveryFollowerCountLabel.text = [NSString stringWithFormat:@"%@ 关注",plan.followCount];
    cell.discoveryRecordsLabel.text = [NSString stringWithFormat:@"%@ 记录",plan.tryTimes];

    //显示置顶的角标
    if ([plan.cornerMask isEqualToString:@"top"]){
        cell.cornerMask.image = [Theme topImageMask];
    }else{
        cell.cornerMask.image = nil;
    }
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
    
    
    if ([segue.identifier isEqualToString:@"showShuffleView"]) {
        ShuffleViewController *svc = segue.destinationViewController;
        svc.svcDelegate = self; //用于使用相机回调函数
    }else{
        if ([segue.identifier isEqualToString:@"showPostDetailFromDiscovery"]) { //相机选取照片之后
            PostFeedViewController *pfvc = segue.destinationViewController;
            NSArray *AssetsAndPlan = sender;
            pfvc.assets = [AssetsAndPlan[0] mutableCopy]; //assets
            pfvc.plan = AssetsAndPlan[1]; //plan
            segue.destinationViewController.hidesBottomBarWhenPushed = YES;
        }
        if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"] || [segue.identifier isEqualToString:@"showWishDetailVCOwnerFromDiscovery"]){
            [segue.destinationViewController setPlan:sender];
            segue.destinationViewController.hidesBottomBarWhenPushed = YES;
        }
        
    }
    
}

- (NSFetchRequest *)collectionFetchRequest{
    if (!_collectionFetchRequest) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[AppDelegate getContext]];
        request.predicate = [NSPredicate predicateWithFormat:@"discoverIndex != nil"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"discoverIndex" ascending:YES]];
        
        _collectionFetchRequest = request;
    }
    return _collectionFetchRequest;
}

#pragma mark - 加号浮云

- (void)didFinishSelectingImageAssets:(NSArray *)assets forPlan:(Plan *)plan{
    //asset could be either UIImage or PHAsset
    if (assets && plan) {
        [self performSegueWithIdentifier:@"showPostDetailFromDiscovery" sender:@[assets,plan]];
    }
}

- (void)didPressCreatePlanButton:(ShuffleViewController *)svc{
    [self performSegueWithIdentifier:@"showPostViewFromDiscovery" sender:nil];
}

- (void)showShuffView{
    [self performSegueWithIdentifier:@"showShuffleView" sender:nil];
}


- (void)setUpNavigationItem
{
    if ([User isSuperUser]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navInviteDefault]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showInvitationView)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navAddDefault]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showShuffView)];
}

- (void)showInvitationView{
    [self performSegueWithIdentifier:@"showInvitationView" sender:nil];
}

#pragma mark - 长按事件可显示相关信息
- (void)longPressed:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        Plan *plan = [self.collectionFetchedRC objectAtIndexPath:indexPath];
        NSString *msg = [NSString stringWithFormat:@"用户id:%@\n事件id:%@\n事件名:%@",plan.owner.ownerId,plan.planId,plan.planTitle];
        
        //显示弹出提示窗口
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark - 下拉菜单 

- (void)showCircleList{
    if (self.dropdownView) {
        if (!self.dropdownView.isOpen){
            self.tabBarController.tabBar.hidden = YES;
            [self.dropdownView showFromNavigationController:self.navigationController withContentView:self.tableView];
        }else{
            [self.dropdownView hide];
        }
    }
}

- (void)dropdownViewDidHide:(LMDropdownView *)dropdownView{
    self.tabBarController.tabBar.hidden = NO;
}

#define cellHeight 38.0f

- (LMDropdownView *)dropdownView{
    if (!_dropdownView) {
        _dropdownView = [LMDropdownView dropdownView];
        _dropdownView.delegate = self;
        self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.tableFetchedRC.fetchedObjects.count * cellHeight);
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];

    }
    return _dropdownView;
}

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Circle"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleListCell"];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.textLabel.text = circle.circleName;
    cell.backgroundColor = [UIColor clearColor];
    
    //设置选中颜色
    cell.selectionStyle = UITableViewCellSeparatorStyleSingleLine;
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [SystemUtil colorFromHexString:@"#D7EBEB"];
    [cell setSelectedBackgroundView:bgColorView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if (![[User currentCircleId] isEqualToString:circle.circleId]) { //当选择了与当前不同的圈子时才执行操作
        self.navigationItem.title = @"正在切换圈子...";
        
        //发送切换圈子请求
        [self.fetchCenter switchToCircle:circle.circleId completion:^{
                        
            //刷新发现页列表
            [self getDiscoveryList];
        }];
    }
    [self.dropdownView hide];
}


@end




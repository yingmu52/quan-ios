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
#import "LMDropdownView.h"
#import "CircleListCell.h"
#import "CircleSettingViewController.h"
#import "CircleCreationViewController.h"
@interface DiscoveryVCData () <FetchCenterDelegate,LMDropdownViewDelegate,CircleSettingViewControllerDelegate,CircleCreationViewControllerDelegate>
@property (nonatomic,strong) LMDropdownView *dropdownView;
@property (nonatomic,weak) Circle *currentCircle;
@property (nonatomic,strong) NSArray *presentingCircleIds;
@end

@implementation DiscoveryVCData

- (Circle *)currentCircle{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if (!circle) {
        circle = self.tableFetchedRC.fetchedObjects.firstObject;
    }
    return circle;
}

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
    [self.fetchCenter getCircleList:^(NSArray *circleIds) {
        self.presentingCircleIds = circleIds;
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.gestureRecognizers = nil;
}

- (void)getDiscoveryList{
    [self.fetchCenter getDiscoveryList:self.collectionFetchedRC.fetchedObjects.mutableCopy
                            completion:^(NSString *circleTitle)
    {
        if (!self.navigationItem.title) {
            //设置导航标题
            self.navigationItem.title = circleTitle;
        }
    }];
}

- (void)switchToCircle:(Circle *)circle{
    [self.fetchCenter switchToCircle:circle.circleId completion:^{
        [self setUpRightBarItem];
        self.navigationItem.title = circle.circleName;
        //刷新发现页列表
        [self getDiscoveryList];
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
    if ([segue.identifier isEqualToString:@"showDiscoveryWishDetail"] || [segue.identifier isEqualToString:@"showWishDetailVCOwnerFromDiscovery"]){
        [segue.destinationViewController setPlan:sender];
        segue.destinationViewController.hidesBottomBarWhenPushed = YES;
    }
    if ([segue.identifier isEqualToString:@"showCircleSettingView"]) {
        CircleSettingViewController *csc = segue.destinationViewController;
        csc.delegate = self;
        csc.circle = self.currentCircle;
    }
    if ([segue.identifier isEqualToString:@"showCircleCreationView"]) {
        CircleCreationViewController *ccc = segue.destinationViewController;
        ccc.delegate = self;
    }
    
}

- (void)didFinishCreatingCircle:(Circle *)circle{
    [self switchToCircle:circle];
}


- (void)didFinishDeletingCircle{
    Circle *circle = self.tableFetchedRC.fetchedObjects.firstObject;
    if (![circle.ownerId isEqualToString:[User uid]]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self switchToCircle:circle];
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

- (void)setUpNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navInviteDefault]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showInvitationView)];
    [self setUpRightBarItem];
}

- (void)setUpRightBarItem{
    Circle *circle = [Circle getCircle:[User currentCircleId]];
    if ([circle.ownerId isEqualToString:[User uid]]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navSettingIcon]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(showCircleSettingView)];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)showCircleSettingView{
    [self performSegueWithIdentifier:@"showCircleSettingView" sender:nil];
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
        [alert addAction:[UIAlertAction actionWithTitle:@"点击可复制内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //把msg的内容复制到粘帖版上
            [[UIPasteboard generalPasteboard] setString:msg];
        }]];
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

#define cellHeight 65.0

- (LMDropdownView *)dropdownView{
    if (!_dropdownView) {
        _dropdownView = [LMDropdownView dropdownView];
        _dropdownView.delegate = self;
        
        CGFloat height = self.tableFetchedRC.fetchedObjects.count * cellHeight;
        if (height > 460.0) height = 460;
        self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),height);
        self.tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        
        //设置“新增圈子”的背景视图高度
        CGRect frame = self.tableView.tableHeaderView.frame;
        frame.size.height = 60.0;
        self.tableView.tableHeaderView.frame = frame;
        
    }
    return _dropdownView;
}

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Circle"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circleId IN %@ OR ownerId == %@",self.presentingCircleIds,[User uid]];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (CircleListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CircleListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleListCell"];

    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.circleListTitle.text = circle.circleName;
    cell.circleListSubtitle.text = circle.circleDescription;
    [cell.circleListImageView downloadImageWithImageId:circle.imageId size:FetchCenterImageSize100];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.dropdownView hide];
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if (![[User currentCircleId] isEqualToString:circle.circleId]) { //当选择了与当前不同的圈子时才执行操作
        self.navigationItem.title = @"正在切换圈子...";
        //发送切换圈子请求
        [self switchToCircle:circle];
    }
}

- (IBAction)buttonPressedForCreatingCircle{
    [self performSegueWithIdentifier:@"showCircleCreationView" sender:nil];
    [self.dropdownView hide];
}


@end




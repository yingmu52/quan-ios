//
//  CircleDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/28/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "MSCollectionCell.h"
#import "WishDetailVCOwner.h"
#import "PostViewController.h"
#import "CircleEditViewController.h"
#import "MemberListViewController.h"
//#import "InvitationViewController.h"
#import "MSWXShareManager.h"
#import "CircleDetailHeader.h"

@interface CircleDetailViewController () <UICollectionViewDelegateFlowLayout,MSSuperViewControllerDelegate>
@property (nonatomic,weak) IBOutlet CircleDetailHeader *headerView;
@property (nonatomic,strong) NSNumber *currentPage;
@property (nonatomic,strong) UIAlertController *moreActionSheet;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@property (nonatomic,strong) UIButton *cameraButton;
@property (nonatomic) CGFloat lastContentOffSet; // for camera animation

@end

@implementation CircleDetailViewController

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy\\MM\\dd";
    }
    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.superVCDelegate = self;
    self.allowTransparentNavigationBar = YES;
    [self setUpBackButton:YES];
    [self setupRightBarButtonItem:YES selector:@selector(showMoreOptions)];
    
    [self setupHeaderView];
    [self loadMoreData];
    
    
    //主人态有创建事件入口
    if ([self.circle.ownerId isEqualToString:[User uid]]){
        [self setupPostViewEntry];
    }
    
}


- (void)didScrollWithNavigationBar:(BOOL)isTransparent{
    [self setUpBackButton:isTransparent];
    [self setupRightBarButtonItem:isTransparent selector:@selector(showMoreOptions)];
}


- (void)setupHeaderView{
    [self.headerView setupHeaderView:self.circle];
    
    self.headerView.collectionView.mj_header = nil;
    self.collectionView.mj_footer = nil;
    self.tableView.mj_header = nil;
}


- (IBAction)followButtonPressed{
    [self.fetchCenter followCircleId:self.circle.mUID completion:^{
        [self.headerView.followButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.headerView.followCountLabel.text = [NSString stringWithFormat:@"%@人关注",@(self.circle.nFans.integerValue + 1)];
    }];
}

#pragma mark - Data Source

- (void)loadMoreData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"mUID"];
    [self.fetchCenter getPlanListInCircleId:self.circle.mUID
                                  localList:localList
                                     onPage:self.currentPage
                                 completion:^(NSNumber *currentPage,
                                              NSNumber *totalPage,
                                              NSArray *topMemberList)
    {
        if ([currentPage isEqualToNumber:totalPage]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            self.currentPage = @(currentPage.integerValue + 1);
            [self.tableView.mj_footer endRefreshing];
        }
        
        
        if (!self.collectionFetchedRC.fetchedObjects.count) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
            request.predicate = [NSPredicate predicateWithFormat:@"mUID IN %@",topMemberList];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mLastReadTime" ascending:YES]];
            self.collectionFetchRequest = request;
            
            NSError *error;
            [self.collectionFetchedRC performFetch:&error];
            if (!error) {
                [self.collectionView reloadData];
                self.collectionFetchedRC.delegate = nil;
            }
        }
    }];
}


- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circle.mUID == %@",self.circle.mUID];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mUpdateTime" ascending:NO]];
    }
    return _tableFetchRequest;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    NSString *segue =
    [plan.owner.mUID isEqualToString:[User uid]] ?
    @"showWishDetailOwnerFromCircleDetail" : @"showWishDetailFromCircleDetail";
    [self performSegueWithIdentifier:segue sender:plan];
}



- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleDetailCell"];
    [cell.ms_imageView1 downloadImageWithImageId:plan.mCoverImageId size:FetchCenterImageSize400];
    cell.ms_title.text = plan.mTitle;
    [cell.ms_imageView2 downloadImageWithImageId:plan.owner.mCoverImageId size:FetchCenterImageSize100];
    cell.ms_subTitle.text = plan.owner.mTitle;
    cell.ms_dateLabel.text = [[self.dateFormatter stringFromDate:plan.mUpdateTime] stringByAppendingString:@"更新"];
    cell.ms_textView.text = plan.mDescription;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 155.0f;
}

- (MSCollectionCell *)collectionView:(UICollectionView *)collectionView
              cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSCollectionCell *cell = (MSCollectionCell *)
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CircleDetailTopMemberCell"
                                              forIndexPath:indexPath];
    if (indexPath.row != 0) {
        cell.ms_imageView2.image =
        [UIImage imageNamed:[NSString stringWithFormat:@"top%@_head_icon",@(indexPath.row)]];
    }
    Owner *owner = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    [cell.ms_imageView1 downloadImageWithImageId:owner.mCoverImageId size:FetchCenterImageSize100];
    cell.ms_titleLabel.text = owner.mTitle;
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((CGRectGetWidth(collectionView.frame) - 28 - 18) * 0.25,collectionView.frame.size.height);
}


#pragma mark - 点点点入口 

- (UIAlertController *)moreActionSheet{
    if (!_moreActionSheet) {
        _moreActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *memberListOption =
        [UIAlertAction actionWithTitle:@"圈子成员列表"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action)
         {
             [self performSegueWithIdentifier:@"showMemberListView" sender:nil];
         }];
        [_moreActionSheet addAction:memberListOption];
        
        if ([self.circle.ownerId isEqualToString:[User uid]]) {
            UIAlertAction *editOption =
            [UIAlertAction actionWithTitle:@"编辑圈子资料"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action)
             {
                 [self performSegueWithIdentifier:@"showCircleEditingView" sender:nil];
             }];
            
            UIAlertAction *inviteOption =
            [UIAlertAction actionWithTitle:@"邀请成员加入"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action)
             {
                 self.hud.label.text = @"正在获取邀请链接...";
                 [self.hud showAnimated:YES];
                 [self.fetchCenter getH5invitationUrlWithCircleId:self.circle.mUID
                                                       completion:^(NSString *urlString)
                  {
                      if (urlString.length > 0) {
                          [MSWXShareManager share:@"邀请好友"
                                      description:[NSString stringWithFormat:@"%@ 邀请你加入圈子",[User userDisplayName]]
                                         imageURL:[self.fetchCenter urlWithImageID:self.circle.mCoverImageId
                                                                              size:FetchCenterImageSize400]
                                            h5url:urlString];
//                          [self performSegueWithIdentifier:@"showInvitationView" sender:urlString];
                      }
                      [self.hud hideAnimated:YES];
                      self.hud = nil;
                  }];
             }];
            
            UIAlertAction *deleteOption =
            [UIAlertAction actionWithTitle:@"删除这个圈子"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action)
             {
                 [self deleteCircle];
             }];
            [_moreActionSheet addAction:editOption];
            [_moreActionSheet addAction:inviteOption];
            [_moreActionSheet addAction:deleteOption];
        }else{
            UIAlertAction *quitOption =
            [UIAlertAction actionWithTitle:@"退出这个圈子"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * _Nonnull action)
             {
                 [self showQuitCircleAlert];
             }];
            [_moreActionSheet addAction:quitOption];
            
        }
        
        [_moreActionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    }
    return _moreActionSheet;
}

- (void)showMoreOptions{
    //hide camera if needed
    if (self.cameraButton.isUserInteractionEnabled) [self animateCameraIcon:YES];
    
    [self presentViewController:self.moreActionSheet animated:YES completion:nil];
}

- (void)showQuitCircleAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出这个圈子?"
                                                                   message:self.circle.mTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                  [spinner startAnimating];
                                  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
                                  [self.fetchCenter quitCircle:self.circle.mUID completion:^{
                                      [spinner stopAnimating];
                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                  }];
                              }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void)deleteCircle{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除圈子?"
                                                                   message:self.circle.mTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                  [spinner startAnimating];
                                  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
                                  [self.fetchCenter deleteCircle:self.circle.mUID
                                                      completion:^
                                   {
                                       [spinner stopAnimating];
                                       [self.navigationController popToRootViewControllerAnimated:YES];
                                   }];
                              }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    
    NSArray *wishdetails = @[@"showWishDetailOwnerFromCircleDetail",@"showWishDetailFromCircleDetail"];
    if ([wishdetails containsObject:segue.identifier]) {
        [segue.destinationViewController setPlan:sender];
    }

    if ([segue.identifier isEqualToString:@"showPostViewFromCircleDetail"]) {
        PostViewController *pvc = segue.destinationViewController;
        pvc.circle = self.circle;
    }
    
    if ([segue.identifier isEqualToString:@"showCircleEditingView"]) {
        CircleEditViewController *cec = segue.destinationViewController;
        cec.circle = self.circle;
    }
    if ([segue.identifier isEqualToString:@"showMemberListView"]) {
        MemberListViewController *mlc = segue.destinationViewController;
        mlc.circle = self.circle;
    }
    
//    if ([segue.identifier isEqualToString:@"showInvitationView"]) {
//        InvitationViewController *ivc = segue.destinationViewController;
//        ivc.titleText = @"邀请好友";
//        ivc.sharedContentTitle = [NSString stringWithFormat:@"%@ 邀请你加入圈子",[User userDisplayName]];
//        ivc.sharedContentDescription = [NSString stringWithFormat:@"【%@】\n%@",self.circle.mTitle,self.circle.mDescription];
//        if (self.circle.mCoverImageId.length > 0) {
//            ivc.imageUrl = [self.fetchCenter urlWithImageID:self.circle.mCoverImageId
//                                                       size:FetchCenterImageSize400];
//        }
//        ivc.h5Url = sender;
//    }
}


#pragma mark - Camera 

- (void)showPostView{
    [self performSegueWithIdentifier:@"showPostViewFromCircleDetail" sender:nil];
}

- (void)setupPostViewEntry{
    
    UIImage *cameraIcon = [UIImage imageNamed:@"tab_ic_plus"];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:cameraIcon forState:UIControlStateNormal];
    addButton.hidden = NO;
    
    
    UIWindow *topView = [[UIApplication sharedApplication] keyWindow];
    
    CGFloat trailing = 58.0/640 * self.view.frame.size.width;
    CGFloat bottom = 32.0/1136 * self.view.frame.size.height;
    
    CGFloat width = cameraIcon.size.width;
    CGFloat height = cameraIcon.size.height;
    [addButton setFrame:CGRectMake(topView.frame.size.width - trailing - width,
                                       topView.frame.size.height - bottom - height,
                                       width,
                                       height)];
    [topView addSubview:addButton];
    
    [addButton addTarget:self action:@selector(showPostView)
            forControlEvents:UIControlEventTouchUpInside];
    self.cameraButton = addButton;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffSet = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.lastContentOffSet < scrollView.contentOffset.y) {
        //hide camera
        if (self.cameraButton.isUserInteractionEnabled) [self animateCameraIcon:YES];
        
    }else{
        //show camera
        if (!self.cameraButton.isUserInteractionEnabled) [self animateCameraIcon:NO];
    }
    
}

- (void)animateCameraIcon:(BOOL)shouldHideCamera{
    CGFloat movingDistance = CGRectGetHeight(self.view.frame) * 0.5f;
    if (shouldHideCamera){
        [UIView animateWithDuration:0.3 animations:^{
            self.cameraButton.center = CGPointMake(self.cameraButton.center.x,
                                                   self.cameraButton.center.y + movingDistance);
            self.cameraButton.userInteractionEnabled = NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.cameraButton.center = CGPointMake(self.cameraButton.center.x,
                                                   self.cameraButton.center.y - movingDistance);
        }];
        self.cameraButton.userInteractionEnabled = YES;
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.cameraButton) {
        self.cameraButton.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.cameraButton){
        self.cameraButton.hidden = YES;
    }
}
@end













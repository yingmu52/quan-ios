//
//  CircleDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/28/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "NavigationBar.h"
#import "MSCollectionCell.h"
#import "WishDetailVCOwner.h"
#import "PostViewController.h"
#import "CircleEditViewController.h"
#import "MemberListViewController.h"
#import "InvitationViewController.h"

@interface CircleDetailViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) IBOutlet UIImageView *circleImageView;
@property (nonatomic,weak) IBOutlet UILabel *circleTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *followCountLabel;
@property (nonatomic,weak) IBOutlet UIButton *followButton;
@property (nonatomic,weak) IBOutlet UITextView *circleDescriptionTextView;

@property (nonatomic,strong) NSNumber *currentPage;
@property (nonatomic,strong) UIAlertController *moreActionSheet;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
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
    [self setUpBackButton:YES];
    [self setupHeaderView];
    [self loadMoreData];
    
    //点点点入口
    UIButton *moreBtn = [Theme buttonWithImage:[Theme navMoreButtonDefault]
                                        target:self
                                      selector:@selector(showMoreOptions)
                                         frame:CGRectNull]; //使用真实大小
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
}

- (void)setupHeaderView{
    self.circleImageView.layer.cornerRadius = 3.0f;
    [self.circleImageView downloadImageWithImageId:self.circle.imageId
                                              size:FetchCenterImageSize400];
    self.circleTitleLabel.text = self.circle.circleName;
    self.followCountLabel.text = [NSString stringWithFormat:@"%@人关注",self.circle.nFans];
    self.circleDescriptionTextView.text = self.circle.circleDescription;
    self.circleDescriptionTextView.textContainerInset = UIEdgeInsetsZero;
    self.circleDescriptionTextView.textColor = [UIColor whiteColor];
    
    self.collectionView.mj_header = nil;
    self.collectionView.mj_footer = nil;
    self.tableView.mj_header = nil;

    
    
    if (self.circle.isFollowable.boolValue) {
        self.followButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.followButton.layer.borderWidth = 1.0f;
        self.followButton.layer.cornerRadius = 11.0f; // 高的一半
        
        if (self.circle.circleType.integerValue == CircleTypeFollowed) {
            [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
            self.followButton.enabled = NO;
            NSLog(@"圈子已经关注");
        }
    }else{
        NSLog(@"圈子不允许被关注");
        self.followButton.hidden = YES;
    }
}


- (IBAction)followButtonPressed{
    [self.fetchCenter followCircleId:self.circle.circleId completion:^{
        [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
    }];
}

#pragma mark - Data Source

- (void)loadMoreData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"planId"];
    [self.fetchCenter getPlanListInCircleId:self.circle.circleId
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
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
        request.predicate = [NSPredicate predicateWithFormat:@"mUID IN %@",topMemberList];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mLastReadTime" ascending:YES]];
        self.collectionFetchRequest = request;
        [self.collectionView reloadData];
    }];
}


- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circle.circleId == %@",self.circle.circleId];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    }
    return _tableFetchRequest;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showWishDetailViewController" sender:plan];
}



- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleDetailCell"];
    [cell.ms_imageView1 downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize400];
    cell.ms_title.text = plan.planTitle;
    [cell.ms_imageView2 downloadImageWithImageId:plan.owner.mCoverImageId size:FetchCenterImageSize100];
    cell.ms_subTitle.text = plan.owner.mTitle;
    cell.ms_dateLabel.text = [[self.dateFormatter stringFromDate:plan.updateDate] stringByAppendingString:@"更新"];
    cell.ms_textView.text = plan.detailText;
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
    return CGSizeMake((CGRectGetWidth(collectionView.frame) - 28 - 18) * 0.25,54.0f);
}

#pragma mark - Navigation Bar Transparency

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self polishNavigationBar:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self polishNavigationBar:NO];
}

- (void)polishNavigationBar:(BOOL)isClear{
    NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
    if (isClear) {
        [nav showClearBackground];
    }else{
        [nav showDefaultBackground];
    }
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
                 [self.fetchCenter getH5invitationUrlWithCircleId:self.circle.circleId
                                                       completion:^(NSString *urlString)
                  {
                      if (urlString.length > 0) {
                          [self performSegueWithIdentifier:@"showInvitationView" sender:urlString];
                      }
                      
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
    [self presentViewController:self.moreActionSheet animated:YES completion:nil];
}

- (void)showQuitCircleAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出这个圈子?"
                                                                   message:self.circle.circleName
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                  [spinner startAnimating];
                                  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
                                  [self.fetchCenter quitCircle:self.circle.circleId completion:^{
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
                                                                   message:self.circle.circleName
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                  [spinner startAnimating];
                                  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
                                  [self.fetchCenter deleteCircle:self.circle.circleId
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
    
    
    if ([segue.identifier isEqualToString:@"showWishDetailViewController"]) {
        [segue.destinationViewController setPlan:sender];
    }

//    if ([segue.identifier isEqualToString:@"showPostFromPlansView"]) {
//        PostViewController *pvc = segue.destinationViewController;
//        pvc.circle = self.circle;
//    }
    
    if ([segue.identifier isEqualToString:@"showCircleEditingView"]) {
        CircleEditViewController *cec = segue.destinationViewController;
        cec.circle = self.circle;
    }
    if ([segue.identifier isEqualToString:@"showMemberListView"]) {
        MemberListViewController *mlc = segue.destinationViewController;
        mlc.circle = self.circle;
    }
    
    if ([segue.identifier isEqualToString:@"showInvitationView"]) {
        InvitationViewController *ivc = segue.destinationViewController;
        ivc.titleText = @"邀请好友";
        ivc.sharedContentTitle = [NSString stringWithFormat:@"%@ 邀请你加入圈子",[User userDisplayName]];
        ivc.sharedContentDescription = [NSString stringWithFormat:@"【%@】\n%@",self.circle.circleName,self.circle.circleDescription];
        if (self.circle.imageId.length > 0) {
            ivc.imageUrl = [self.fetchCenter urlWithImageID:self.circle.imageId
                                                       size:FetchCenterImageSize400];
        }
        ivc.h5Url = sender;
    }
}
@end

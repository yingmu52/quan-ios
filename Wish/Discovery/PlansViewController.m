//
//  PlansViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-28.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "PlansViewController.h"
#import "PostViewController.h"
#import "EmptyCircleView.h"
#import "CircleEditViewController.h"
#import "MemberListViewController.h"
#import "InvitationViewController.h"
@interface PlansViewController () <EmptyCircleViewDelegate>
@property (nonatomic,strong) EmptyCircleView *emptyView;
@property (nonatomic,strong) NSNumber *currentPage;
@property (nonatomic,strong) UIAlertController *moreActionSheet;
@end

@implementation PlansViewController

- (void)viewWillAppear:(BOOL)animated{    
    [super viewWillAppear:animated];
    if (!self.collectionFetchedRC.fetchedObjects.count) {
        [self setUpEmptyView];
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
    
    
    if (self.circle) { //圈子事件页
        CGRect frame = CGRectMake(0,0, 25,25);
        UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                            target:self.navigationController
                                          selector:@selector(popViewControllerAnimated:)
                                             frame:frame];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.title = self.circle.circleName;
        
        
        //点点点入口
        UIButton *moreBtn = [Theme buttonWithImage:[Theme navMoreButtonDefault]
                                            target:self
                                          selector:@selector(showMoreOptions)
                                             frame:CGRectNull]; //使用真实大小
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
        
        [self loadMoreData];
    }

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
    
    if ([segue.identifier isEqualToString:@"showPostFromPlansView"]) {
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

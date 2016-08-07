//
//  CircleSettingViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-04.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleSettingViewController.h"
#import "Theme.h"
#import "FetchCenter.h"
#import "CircleEditViewController.h"
#import "MemberListViewController.h"
#import "InvitationViewController.h"
#import "MBProgressHUD.h"
@interface CircleSettingViewController () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

@implementation CircleSettingViewController

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    
    //Left Bar Button
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    if ([self.circle.ownerId isEqualToString:[User uid]]) {
        UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                              target:self
                                            selector:@selector(deleteCircle:)
                                               frame:frame];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    }
    //Title
    self.navigationItem.title = @"设置";
}

- (void)deleteCircle:(UIButton *)sender{
    
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
             self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sender];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 5.0 : 2.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2.5;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.label.text = @"加载邀请链接...";
        [self.fetchCenter getH5invitationUrlWithCircleId:self.circle.circleId
                                              completion:^(NSString *urlString)
        {
            [hud hideAnimated:YES];
            if (urlString.length > 0) {
                [self performSegueWithIdentifier:@"showInvitationView" sender:urlString];
            }
            
        }];
    }
}




@end




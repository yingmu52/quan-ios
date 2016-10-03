//
//  MemberListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-09.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MemberListViewController.h"
#import "Theme.h"
#import "UIImageView+ImageCache.h"
@interface MemberListViewController ()

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell

}


- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"mUID"];
    [self.fetchCenter getMemberListForCircleId:self.circle.circleId
                                     localList:localList
                                    completion:^(NSArray *memberIDs)
    {
#warning 建议改成多对多的关系
        //成圆与圈子是多对多的关系，数据模型里面没有这部分的关系。因此直接从服务器撮信息
        self.tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
        self.tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"mUID IN %@",memberIDs];
        self.tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mLastReadTime" ascending:YES]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
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
    
    //Right Bar Button
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navInviteDefault]
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:nil];
    
    //Title
    self.navigationItem.title = @"管理成员";
}

//- (NSFetchRequest *)tableFetchRequest{
//    if (!_tableFetchRequest) {
//        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
//        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY circles.circleId = %@",self.circle.circleId];
//        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ownerName" ascending:NO]];
//    }
//    return _tableFetchRequest;
//}

- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = indexPath.row == 0 ? @"MemberListCellAdmin" : @"MemberListCellNormal";
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(MSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Owner *owner = [self.tableFetchedRC objectAtIndexPath:indexPath];
    
    if (owner.mTitle.length > 0) {
        cell.ms_title.text = owner.mTitle;
    }else{
        cell.ms_subTitle.text = [NSString stringWithFormat:@"用户%@",owner.mUID];
    }
    [cell.ms_imageView1 downloadImageWithImageId:owner.mCoverImageId
                                            size:FetchCenterImageSize100];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.circle.ownerId isEqualToString:[User uid]]) { //只有圈主才有删除权限
        Owner *owner = [self.tableFetchedRC objectAtIndexPath:indexPath];
        if (![owner.mUID isEqualToString:[User uid]]) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *delMember = [UIAlertAction actionWithTitle:@"删除该成员" style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除该成员？"
                                                                                                           message:owner.mTitle
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                                            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                [self.fetchCenter deleteMember:owner.mUID inCircle:self.circle.circleId completion:nil];
                                            }];
                                            [alert addAction:confirm];
                                            [self presentViewController:alert animated:YES completion:nil];
                                            
                                        }];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [actionSheet addAction:delMember];
            [self presentViewController:actionSheet animated:YES completion:nil];
    
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end

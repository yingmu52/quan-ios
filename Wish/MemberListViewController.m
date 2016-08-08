//
//  MemberListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-09.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MemberListViewController.h"
#import "Theme.h"
#import "MemberListCell.h"
#import "UIImageView+ImageCache.h"
#import "MJRefresh.h"
@interface MemberListViewController ()

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(loadNewData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}


- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"ownerId"];
    [self.fetchCenter getMemberListForCircleId:self.circle.circleId
                                     localList:localList
                                    completion:^(NSArray *memberIDs)
    {
#warning 建议改成多对多的关系
        //成圆与圈子是多对多的关系，数据模型里面没有这部分的关系。因此直接从服务器撮信息
        self.tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
        self.tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"ownerId IN %@",memberIDs];
        self.tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ownerName" ascending:NO]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Owner *owner = [self.tableFetchedRC objectAtIndexPath:indexPath];
    NSString *identifier = [owner.ownerId isEqualToString:self.circle.ownerId] ? @"MemberListCellAdmin" : @"MemberListCellNormal";
    MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureTableViewCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureTableViewCell:(MemberListCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Owner *owner = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if (owner.ownerName.length > 0) {
        cell.nameLabel.text = owner.ownerName;
    }else{
        cell.nameLabel.text = @"该用户还没有设置名字";
    }
    [cell.headImageView downloadImageWithImageId:owner.headUrl
                                            size:FetchCenterImageSize100];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Owner *owner = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if (![owner.ownerId isEqualToString:[User uid]]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *delMember = [UIAlertAction actionWithTitle:@"删除该成员" style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除该成员？"
                                                                           message:owner.ownerName
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.fetchCenter deleteMember:owner.ownerId inCircle:self.circle.circleId completion:nil];
            }];
            [alert addAction:confirm];
            [self presentViewController:alert animated:YES completion:nil];

        }];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [actionSheet addAction:delMember];
        [self presentViewController:actionSheet animated:YES completion:nil];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end

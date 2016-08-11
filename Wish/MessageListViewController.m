//
//  MessageListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-01.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MessageListViewController.h"
#import "Theme.h"
#import "FetchCenter.h"
#import "MessageCell.h"
#import "Owner.h"
#import "UIImageView+WebCache.h"
#import "FeedDetailViewController.h"

@interface MessageListViewController ()
@property (nonatomic,strong) NSTimer *messageNotificationTimer;
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell
    self.tableView.backgroundColor = [Theme homeBackground];
    
    
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(loadNewData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];

    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.tabBarItem.badgeValue.length > 0) {
        [self loadNewData];
    }
}

- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"messageId"];
    [self.fetchCenter getMessageListWithLocalList:localList
                                           onPage:nil
                                       completion:^(NSNumber *currentPage, NSNumber *totalPage)
    {
        self.currentPage = @(2); //这个currentPage其实是下一页的意思
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        [self.tabBarController.tabBar.selectedItem setBadgeValue:nil]; //去掉好点计数
    }];
}

- (void)loadMoreData{
    
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"messageId"];
    [self.fetchCenter getMessageListWithLocalList:localList
                                           onPage:self.currentPage
                                       completion:^(NSNumber *currentPage, NSNumber *totalPage)
    {
        if ([currentPage isEqualToNumber:totalPage]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            self.currentPage = @(currentPage.integerValue + 1);
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    self.navigationItem.title = @"消息"; 
    UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                          target:self
                                        selector:@selector(clearAllMessages)
                                           frame:frame];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    self.navigationItem.rightBarButtonItem.enabled = self.tableFetchedRC.fetchedObjects.count > 0;
}


#pragma mark - clear all message 
- (void)clearAllMessages{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"确定要清空所有消息吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.fetchCenter clearAllMessages:nil];
    }];
    [actionSheet addAction:confirm];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];    
}

#pragma mark - Table view

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height - 568.0f) >= 0)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0f;
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(MessageCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Message *message = [self.tableFetchedRC objectAtIndexPath:indexPath];
    
    [cell.profilePictureImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:message.owner.headUrl size:FetchCenterImageSize100]];
    [cell.feedImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:message.picurl size:FetchCenterImageSize100]];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:message.owner.ownerName
                                                                                attributes:@{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00B8C2"]}];
    [content appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"发表了一条评论：%@",message.content]]];
    cell.contentLabel.attributedText = content;
    
    
    //displaying date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    cell.dateLabel.text = [formatter stringFromDate:message.createTime];
    
    //    cell.backgroundColor = message.isRead.boolValue ? [self normalColor] : [self highlightColor];
}

- (UIColor *)normalColor{
    return [SystemUtil colorFromHexString:@"#F4F9F7"];
}
- (UIColor *)highlightColor{
    return [SystemUtil colorFromHexString:@"#E7F0ED"];
    
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.backgroundColor = [self highlightColor];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [self normalColor];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    Message *message = [self.tableFetchedRC objectAtIndexPath:indexPath];
    message.isRead = @(YES);
    [self performSegueWithIdentifier:@"showFeedDetailFromMessage" sender:message.feedsId];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFeedDetailFromMessage"]) {
        [segue.destinationViewController setFeedId:sender];
    }
    segue.destinationViewController.hidesBottomBarWhenPushed = YES;
}

#pragma mark - Override Methods

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"targetOwnerId = %@",[User uid]];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]];
        [_tableFetchRequest setFetchBatchSize:3];
    }
    return _tableFetchRequest;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [super controllerDidChangeContent:controller];
    self.navigationItem.rightBarButtonItem.enabled = controller.fetchedObjects.count > 0;
}


@end




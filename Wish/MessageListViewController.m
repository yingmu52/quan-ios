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
}


- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"messageId"];
    [self.fetchCenter getMessageListWithLocalList:localList
                                       completion:^{
       [self.tableView.mj_header endRefreshing];
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
        [self.fetchCenter clearAllMessages:^{
            for (Message *message in self.tableFetchedRC.fetchedObjects) {
                [message.managedObjectContext deleteObject:message];
            }
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
        }];
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




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

@interface MessageListViewController () <FetchCenterDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSFetchedResultsController *fetchedRC;
@end

@implementation MessageListViewController


- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell
    self.tableView.backgroundColor = [Theme homeBackground];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self.fetchCenter getMessageList];
}
- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
//    UIButton *back = [Theme buttonWithImage:[Theme navMenuDefault]
//                                     target:self.slidingViewController
//                                   selector:@selector(anchorTopViewToRightAnimated:)
//                                      frame:frame];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.title = @"消息";
 
    UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                          target:self
                                        selector:@selector(clearAllMessages)
                                           frame:frame];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    self.navigationItem.rightBarButtonItem.enabled = self.fetchedRC.fetchedObjects.count > 0;
}

#pragma mark - clear all message 
- (void)clearAllMessages{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"确定要清空所有消息吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.fetchCenter clearAllMessages];
    }];
    [actionSheet addAction:confirm];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];    
}

- (void)didFinishClearingAllMessages{
    NSManagedObjectContext *context = [AppDelegate getContext];
    for (Message *message in self.fetchedRC.fetchedObjects) {
        [context deleteObject:message];
    }
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
}
#pragma mark - Table view data source

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height - 568.0f) >= 0)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE5){
        return 140.0f/1136 * self.tableView.frame.size.height;
    }else{
        //eariler
        return 150.0f/640 * self.tableView.frame.size.width;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}


- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    Message *message = [self.fetchedRC objectAtIndexPath:indexPath];
    
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
    return cell;
}

- (UIColor *)normalColor{
    return [SystemUtil colorFromHexString:@"#F4F9F7"];
}
- (UIColor *)highlightColor{
    return [SystemUtil colorFromHexString:@"#E7F0ED"];

}
#pragma mark - Table View Delegate 

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.backgroundColor = [self highlightColor];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [self normalColor];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    Message *message = [self.fetchedRC objectAtIndexPath:indexPath];
    message.isRead = @(YES);
    [self performSegueWithIdentifier:@"showFeedDetailFromMessage" sender:message.feedsId];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFeedDetailFromMessage"]) {
        [segue.destinationViewController setFeedId:sender];
    }
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - NSFetchedResultsController Delegate 

- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC){
        
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
        request.predicate = [NSPredicate predicateWithFormat:@"targetOwnerId = %@",[User uid]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]];
        [request setFetchBatchSize:3];
        
        NSFetchedResultsController *newFRC =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:[AppDelegate getContext]
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        self.fetchedRC = newFRC;
        _fetchedRC.delegate = self;
        NSError *error;
        [_fetchedRC performFetch:&error];
        
    }
    return _fetchedRC;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"Message inserted");
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Message deleted");
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"Message updated");
            break;
        default:
            break;
    }
    
}


- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
    self.navigationItem.rightBarButtonItem.enabled = controller.fetchedObjects.count > 0;
    [self.tableView endUpdates];
}


@end




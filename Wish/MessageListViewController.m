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
#import "UIViewController+ECSlidingViewController.h"
#import "UIActionSheet+Blocks.h"
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
    [self.fetchCenter getMessageList];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                     target:self.slidingViewController
                                   selector:@selector(anchorTopViewToRightAnimated:)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.title = @"消息";
 
    UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                          target:self
                                        selector:@selector(clearAllMessages)
                                           frame:frame];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
}

#pragma mark - clear all message 
- (void)clearAllMessages{
    [UIActionSheet showInView:self.view
                    withTitle:@"确定要清空所有消息吗？"
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:@"确定"
            otherButtonTitles:nil
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
                         if ([title isEqualToString:@"确定"]) {
                             [self.fetchCenter clearAllMessages];
                         }
                     }];
}

- (void)didFinishClearingAllMessages{
    NSManagedObjectContext *context = [AppDelegate getContext];
    for (Message *message in self.fetchedRC.fetchedObjects) {
        [context deleteObject:message];
    }
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.0/1136 * self.tableView.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}


- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    Message *message = [self.fetchedRC objectAtIndexPath:indexPath];
    
    UIImage *placeHolder = [UIImage imageNamed:@"placeholder.png"];

    [cell.profilePictureImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:message.owner.headUrl] placeholderImage:placeHolder];
    [cell.feedImageView sd_setImageWithURL:[self.fetchCenter urlWithImageID:message.picurl] placeholderImage:placeHolder];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:message.owner.ownerName
                                                                                attributes:@{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#00B8C2"]}];
    [content appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"发表了一条评论：%@",message.content]]];
    cell.contentLabel.attributedText = content;
    
    
    //displaying date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    cell.dateLabel.text = [formatter stringFromDate:message.createTime];

    return cell;
}

#pragma mark - Table View Delegate 

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.backgroundColor = [SystemUtil colorFromHexString:@"#E7F0ED"];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [SystemUtil colorFromHexString:@"#F4F9F7"];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    Message *message = [self.fetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showFeedDetailFromMessage" sender:message.feedsId];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFeedDetailFromMessage"]) {
        [segue.destinationViewController setFeedId:sender];
    }
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
    [self.tableView endUpdates];
}

#pragma mark - fetch center delegate 

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",info[@"ret"]]
                                message:[NSString stringWithFormat:@"%@",info[@"msg"]]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    
}
@end

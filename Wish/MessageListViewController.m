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
    self.title = @"消息";
    [self.fetchCenter getMessageList];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *back = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                     target:self
                                   selector:@selector(dismissModalViewControllerAnimated:)
                                      frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0/1136 * self.tableView.frame.size.height;
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
    cell.dateLabel.text = [SystemUtil stringFromDate:message.createTime];
    cell.contentLabel.text = message.content;
    return cell;
}

#pragma mark - NSFetchedResultsController Delegate 

- (NSFetchedResultsController *)fetchedRC
{
    if (!_fetchedRC){
        
        //do fetchrequest
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
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


@end

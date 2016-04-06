//
//  FollowingViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-04-04.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowingCell.h"
#import "WishDetailViewController.h"
static NSUInteger numberOfPreloadedFeeds = 3;

@interface FollowingViewController () <FollowingCellDelegate>

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
}

- (void)setUpNavigationItem
{
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.title = @"我的关注";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSArray *localList = [self.collectionFetchedRC.fetchedObjects valueForKey:@"planId"];
    [self.fetchCenter getFollowingList:localList completion:nil];
}

#pragma mark - Table View Delegate and Data Source

- (FollowingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingCell"
                                                          forIndexPath:indexPath];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(FollowingCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    
    //update Plan Info
    cell.headTitleLabel.text = plan.planTitle;
    cell.headDateLabel.text = [NSString stringWithFormat:@"更新于 %@",[SystemUtil stringFromDate:plan.updateDate]];
    cell.delegate = self;
    
    //fetch feeds array
    NSArray *sortedArray = [plan.feeds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]]];
    
    if (sortedArray.count <= numberOfPreloadedFeeds){
        cell.feedsArray = sortedArray;
    }else{
        cell.feedsArray =  [sortedArray subarrayWithRange:NSMakeRange(0, numberOfPreloadedFeeds)];
    }
    
    
    //update User Info
    cell.headUserNameLabel.text = plan.owner.ownerName;
    
    [cell.headProfilePic setCircularImageWithURL:[self.fetchCenter urlWithImageID:plan.owner.headUrl size:FetchCenterImageSize100]
                                        forState:UIControlStateNormal];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 572.0 * 0.5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableFetchedRC.fetchedObjects.count;;
}

#pragma mark - Follwing Cell Delegate

- (void)didPressCollectionCellAtIndex:(NSIndexPath *)indexPath forCell:(FollowingCell *)cell{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:@"showFollowerWishDetail" sender:@[plan,indexPath]];
}

- (void)didPressMoreButtonForCell:(FollowingCell *)cell{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self performSegueWithIdentifier:@"showFollowerWishDetail" sender:plan];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showFollowerWishDetail"]) {
        if ([sender isKindOfClass:[NSArray class]]){
            NSArray *array = (NSArray *)sender;
            WishDetailViewController *wdvc = segue.destinationViewController;
            wdvc.plan = array.firstObject; // refer: didPressCollectionCellAtIndex
            [wdvc.tableView scrollToRowAtIndexPath:array.lastObject
                                          atScrollPosition:UITableViewScrollPositionMiddle
                                                  animated:NO];

        }else{
            [segue.destinationViewController setPlan:sender];
        }
        
    }
}

#pragma mark - Fetch Request 

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"owner.ownerId != %@ && isFollowed == %@",[User uid],@(YES)];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    }
    return _tableFetchRequest;    
}

@end














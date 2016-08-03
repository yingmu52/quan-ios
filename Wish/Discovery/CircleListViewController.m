//
//  CircleListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-20.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "CircleListViewController.h"
#import "Theme.h"
#import "CircleListCell.h"
#import "UIImageView+ImageCache.h"
#import "PlansViewController.h"
@interface CircleListViewController () <UITableViewDelegate>
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation CircleListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //设置“新增圈子”的背景视图高度
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 60.0;
    self.tableView.tableHeaderView.frame = frame;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.title = @"圈子";
    
    

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];

    [self loadMoreData];
}

- (void)loadMoreData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"circleId"];
    [self.fetchCenter getCircleList:localList
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


- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Circle"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

- (CircleListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CircleListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleListCell"];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(CircleListCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.circleListTitle.text = circle.circleName;
    cell.circleListSubtitle.text = circle.circleDescription;
    [cell.circleListImageView downloadImageWithImageId:circle.imageId
                                                  size:FetchCenterImageSize100];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showPlansView" sender:circle];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)buttonPressedForCreatingCircle{
    [self performSegueWithIdentifier:@"showCircleCreationView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showPlansView"]) {
        PlansViewController *pvc = segue.destinationViewController;
        pvc.circle = sender;
    }
}


@end

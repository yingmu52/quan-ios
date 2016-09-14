//
//  CircleListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-20.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "CircleListViewController.h"
#import "Theme.h"
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
}

- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"circleId"];
    [self.fetchCenter getCircleList:localList
                             onPage:nil
                         completion:^(NSNumber *currentPage, NSNumber *totalPage)
     {
         self.currentPage = @(2); //这个currentPage其实是下一页的意思
         [self.tableView.mj_header endRefreshing];
         [self.tableView.mj_footer endRefreshing];
     }];
    
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
    return 78.0;
}

- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleListCell"];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureTableViewCell:(MSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.ms_title.text = circle.circleName;
    cell.ms_subTitle.text = circle.circleDescription;
    [cell.ms_imageView1 downloadImageWithImageId:circle.imageId
                                            size:FetchCenterImageSize200];
    [cell.ms_FeatherImage downloadImageWithImageId:circle.imageId size:FetchCenterImageSize200];
    cell.ms_featherBackgroundView.backgroundColor = [Theme getRandomShortRangeHSBColorWithAlpha:0.1];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showPlansView" sender:circle];
    [User updateAttributeFromDictionary:@{CURRENT_CIRCLE_ID:circle.circleId}];
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

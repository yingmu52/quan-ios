//
//  FollowingCirclesViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/27/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "FollowingCirclesViewController.h"
#import "CircleDetailViewController.h"
@interface FollowingCirclesViewController ()
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation FollowingCirclesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"circleId"];
    [self.fetchCenter getFollowingCircleList:localList
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
    
    [self.fetchCenter getFollowingCircleList:localList
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
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circleType == %@",@(CircleTypeFollowed)];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}

- (void)configureTableViewCell:(MSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.ms_title.text = circle.circleName;
    cell.ms_textView.text = circle.circleDescription;
    
    NSNumber *newPlanCount = circle.newPlanCount;
    if (newPlanCount.integerValue > 0) {
        cell.ms_statusLabel.text = [NSString stringWithFormat:@"%@",newPlanCount];
        cell.ms_statusLabel.hidden = NO;
        cell.ms_imageView2.hidden = NO;
    }else{
        cell.ms_statusLabel.hidden = YES;
        cell.ms_imageView2.hidden = YES;
    }
    
    [cell.ms_imageView1 downloadImageWithImageId:circle.imageId size:FetchCenterImageSize200];
    [cell.ms_FeatherImage downloadImageWithImageId:circle.imageId size:FetchCenterImageSize200];
}


- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingCirclesCell"];
    cell.ms_featherBackgroundView.layer.borderColor = [SystemUtil colorFromHexString:@"#e2e2e2"].CGColor;
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showCircleDetailFromFollowingCircleList" sender:circle];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showCircleDetailFromFollowingCircleList"]) {
        [segue.destinationViewController setCircle:sender];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88.0f;
}

@end

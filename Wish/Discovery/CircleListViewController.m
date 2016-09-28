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

//    self.navigationItem.title = @"圈子";
}

- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"circle.circleId"];
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
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"circle.circleId"];
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


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0 ;
}
//这个方法可以解决footer section颜色不一致问题
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"rank != nil"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}

- (NSString *)tableSectionKeyPath{
    return @"circle.circleId";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [super tableView:tableView numberOfRowsInSection:section] + 1; //第一个是圈子，后k个是事件
}

- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = indexPath.row == 0 ? @"CircleListCell" : @"CircleListTopPlansCell";
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureTableViewCell:(MSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
        Circle *circle = plan.circle;
        cell.ms_title.text = circle.circleName;
        [cell.ms_imageView1 downloadImageWithImageId:circle.imageId
                                                size:FetchCenterImageSize200];
        [cell.ms_FeatherImage downloadImageWithImageId:circle.imageId
                                                  size:FetchCenterImageSize200];
        cell.ms_featherBackgroundView.backgroundColor = [Theme getRandomShortRangeHSBColorWithAlpha:0.1];
        

        NSString *s1 = [NSString stringWithFormat:@"粉丝数：%@",circle.nFans];
        NSMutableAttributedString *as1 = [[NSMutableAttributedString alloc] initWithString:s1];
        if (circle.nFansToday.integerValue > 0) {
            NSString *s2 = [NSString stringWithFormat:@" +%@",circle.nFansToday];
            NSDictionary *attr = @{NSForegroundColorAttributeName:[SystemUtil colorFromHexString:@"#32c9a9"]};
            NSAttributedString *as2 = [[NSAttributedString alloc] initWithString:s2 attributes:attr];
            [as1 appendAttributedString:as2];
        }
        cell.ms_subTitle.attributedText = as1;

    }else{
        NSIndexPath *inp = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        Plan *plan = [self.tableFetchedRC objectAtIndexPath:inp];
        cell.ms_imageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"top%@_icon",@(indexPath.row)]];
        [cell.ms_imageView1 downloadImageWithImageId:plan.owner.headUrl size:FetchCenterImageSize200];
        cell.ms_title.text = plan.owner.ownerName;
        cell.ms_subTitle.text = [NSString stringWithFormat:@"《%@》",plan.planTitle];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
        Circle *circle = plan.circle;
        [self performSegueWithIdentifier:@"showCircleDetailFromMyJoining" sender:circle];
        [User updateAttributeFromDictionary:@{CURRENT_CIRCLE_ID:circle.circleId}];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)buttonPressedForCreatingCircle{
    [self performSegueWithIdentifier:@"showCircleCreationView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showCircleDetailFromMyJoining"]) {
        [segue.destinationViewController setCircle:sender];
    }
}


@end

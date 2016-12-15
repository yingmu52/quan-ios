//
//  CirclePickerViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-25.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CirclePickerViewController.h"
#import "Theme.h"
#import "MSTableViewCell.h"
#import "UIImageView+ImageCache.h"
@interface CirclePickerViewController ()
@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation CirclePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];    
}

- (void)setUpNavigationItem
{
    
    //Left Bar Button
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    //Title
    self.navigationItem.title = @"选择圈子";
}


- (void)loadNewData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"mUID"];
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
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKeyPath:@"mUID"];
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
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"mTypeID != nil"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mCreateTime" ascending:NO]];
    }
    return _tableFetchRequest;
}


- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CirclePickerCell"];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(MSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.ms_title.text = circle.mTitle;
    cell.ms_subTitle.text = circle.mDescription;
    [cell.ms_imageView1 downloadImageWithImageId:circle.mCoverImageId
                                            size:FetchCenterImageSize100];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self.delegate didFinishPickingCircle:circle];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

//
//  CircleDetailViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 9/28/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "NavigationBar.h"
#import "MSCollectionCell.h"
@interface CircleDetailViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) IBOutlet UIImageView *circleImageView;
@property (nonatomic,weak) IBOutlet UILabel *circleTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *followCountLabel;
@property (nonatomic,weak) IBOutlet UIButton *followButton;
@property (nonatomic,weak) IBOutlet UITextView *circleDescriptionTextView;

@property (nonatomic,strong) NSNumber *currentPage;
@end

@implementation CircleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpBackButton:YES];

    self.circleImageView.layer.cornerRadius = 3.0f;
    [self.circleImageView downloadImageWithImageId:self.circle.imageId
                                              size:FetchCenterImageSize400];
    self.circleTitleLabel.text = self.circle.circleName;
    self.followCountLabel.text = [NSString stringWithFormat:@"%@人关注",self.circle.nFans];
    self.circleDescriptionTextView.text = self.circle.circleDescription;
    self.circleDescriptionTextView.textContainerInset = UIEdgeInsetsZero;
    self.circleDescriptionTextView.textColor = [UIColor whiteColor];
    
    self.collectionView.mj_header = nil;
    self.collectionView.mj_footer = nil;
    self.tableView.mj_header = nil;
    
    [self loadMoreData];
}


#pragma mark - Data Source

- (void)loadMoreData{
    NSArray *localList = [self.tableFetchedRC.fetchedObjects valueForKey:@"planId"];
    [self.fetchCenter getPlanListInCircleId:self.circle.circleId
                                  localList:localList
                                     onPage:self.currentPage
                                 completion:^(NSNumber *currentPage,
                                              NSNumber *totalPage,
                                              NSArray *topMemberList)
    {
        if ([currentPage isEqualToNumber:totalPage]) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            self.currentPage = @(currentPage.integerValue + 1);
            [self.tableView.mj_footer endRefreshing];
        }
        
#warning 以后可以用lastReadTime来排列
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
        request.predicate = [NSPredicate predicateWithFormat:@"ownerId IN %@",topMemberList];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ownerId" ascending:NO]];
        self.collectionFetchRequest = request;
        [self.collectionView reloadData];
    }];
}


- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circle == %@",self.circle];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    }
    return _tableFetchRequest;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleDetailCell"];
    cell.textLabel.text = plan.planTitle;
    cell.detailTextLabel.text = plan.detailText;
    return cell;
}


- (MSCollectionCell *)collectionView:(UICollectionView *)collectionView
              cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MSCollectionCell *cell = (MSCollectionCell *)
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CircleDetailTopMemberCell"
                                              forIndexPath:indexPath];
    if (indexPath.row != 0) {
        cell.ms_imageView2.image =
        [UIImage imageNamed:[NSString stringWithFormat:@"top%@_head_icon",@(indexPath.row)]];
    }
    Owner *owner = [self.collectionFetchedRC objectAtIndexPath:indexPath];
    [cell.ms_imageView1 downloadImageWithImageId:owner.headUrl size:FetchCenterImageSize100];
    cell.ms_titleLabel.text = owner.ownerName;
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((CGRectGetWidth(collectionView.frame) - 28 - 18) * 0.25,54.0f);
}

#pragma mark - Navigation Bar Transparency

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self polishNavigationBar:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self polishNavigationBar:NO];
}

- (void)polishNavigationBar:(BOOL)isClear{
    NavigationBar *nav = (NavigationBar *)self.navigationController.navigationBar;
    if (isClear) {
        [nav showClearBackground];
    }else{
        [nav showDefaultBackground];
    }
}

@end

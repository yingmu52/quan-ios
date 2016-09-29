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
#import "WishDetailVCOwner.h"
@interface CircleDetailViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) IBOutlet UIImageView *circleImageView;
@property (nonatomic,weak) IBOutlet UILabel *circleTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *followCountLabel;
@property (nonatomic,weak) IBOutlet UIButton *followButton;
@property (nonatomic,weak) IBOutlet UITextView *circleDescriptionTextView;

@property (nonatomic,strong) NSNumber *currentPage;

@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@end

@implementation CircleDetailViewController

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy\\MM\\dd";
    }
    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton:YES];
    [self setupHeaderView];
    [self loadMoreData];
}

- (void)setupHeaderView{
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

    self.followButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.followButton.layer.borderWidth = 1.0f;
    self.followButton.layer.cornerRadius = 11.0f; // 高的一半
    
}


- (IBAction)followButtonPressed{
    [self.fetchCenter followCircleId:self.circle.circleId completion:^{
        [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
    }];
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
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"circle.circleId == %@",self.circle.circleId];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]];
    }
    return _tableFetchRequest;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showWishDetailViewController"]) {
        [segue.destinationViewController setPlan:sender];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showWishDetailViewController" sender:plan];
}



- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Plan *plan = [self.tableFetchedRC objectAtIndexPath:indexPath];
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleDetailCell"];
    [cell.ms_imageView1 downloadImageWithImageId:plan.backgroundNum size:FetchCenterImageSize400];
    cell.ms_title.text = plan.planTitle;
    [cell.ms_imageView2 downloadImageWithImageId:plan.owner.headUrl size:FetchCenterImageSize100];
    cell.ms_subTitle.text = plan.owner.ownerName;
    cell.ms_dateLabel.text = [[self.dateFormatter stringFromDate:plan.updateDate] stringByAppendingString:@"更新"];
    cell.ms_textView.text = plan.detailText;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 155.0f;
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

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
#import "CircleDetailViewController.h"
#import "WishDetailViewController.h"
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
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MSBase"];
        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"mTypeID != nil"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mSpecialTimestamp" ascending:YES]];
    }
    return _tableFetchRequest;
}

- (NSString *)tableSectionKeyPath{
    return @"mTypeID";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68.0;
}


- (MSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MSBase *entity = [self.tableFetchedRC objectAtIndexPath:indexPath];
    NSString *identifier = [entity isKindOfClass:[Circle class]] ? @"CircleListCell" : @"CircleListTopPlansCell";
    MSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureTableViewCell:(MSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    MSBase *entity = [self.tableFetchedRC objectAtIndexPath:indexPath];

    if ([entity isKindOfClass:[Circle class]]) {
        Circle *circle = (Circle *)entity;
        
        cell.ms_title.text = circle.mTitle;
        [cell.ms_imageView1 downloadImageWithImageId:circle.mCoverImageId
                                                size:FetchCenterImageSize200];
        [cell.ms_FeatherImage downloadImageWithImageId:circle.mCoverImageId
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
    }
    
    if ([entity isKindOfClass:[Plan class]]) {
        
        Plan *plan = (Plan *)entity;
        cell.ms_imageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"top%@_icon",@(indexPath.row)]];
        [cell.ms_imageView1 downloadImageWithImageId:plan.owner.mCoverImageId size:FetchCenterImageSize200];
        cell.ms_title.text = plan.owner.mTitle;
        cell.ms_subTitle.text = [NSString stringWithFormat:@"《%@》",plan.mTitle];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MSBase *entity = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if ([entity isKindOfClass:[Circle class]]) {
        [self performSegueWithIdentifier:@"showCircleDetailFromMyJoining" sender:entity];
        [User updateAttributeFromDictionary:@{CURRENT_CIRCLE_ID:entity.mUID}];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if ([entity isKindOfClass:[Plan class]]) {
        Plan *p = (Plan *)entity;
        NSString *segue =
        [p.owner.mUID isEqualToString:[User uid]] ?
        @"showOwnerWishDetailViewFromCircleList" : @"showNormalWishDetailViewFromCircleList";
        [self performSegueWithIdentifier:segue sender:p];
    }
}

- (IBAction)buttonPressedForCreatingCircle{
    [self performSegueWithIdentifier:@"showCircleCreationView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showCircleDetailFromMyJoining"]) {
        [segue.destinationViewController setCircle:sender];
    }
    
    NSArray *wishdetails = @[@"showNormalWishDetailViewFromCircleList",@"showOwnerWishDetailViewFromCircleList"];
    if ([wishdetails containsObject:segue.identifier]) {
        segue.destinationViewController.hidesBottomBarWhenPushed = YES;
        [segue.destinationViewController setPlan:sender];
    }
}


#pragma mark - Section Border

#define LAYERNAME @"MOTHERFUCKINGBORDER"

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(MSTableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath{

    //清空之前画上的描边
    id l = cell.ms_featherBackgroundView.layer.sublayers.firstObject;
    if ([l isKindOfClass:[CAShapeLayer class]]){
        CAShapeLayer *ly = (CAShapeLayer *)l;
        if ([ly.name isEqualToString:LAYERNAME]) {
            [ly removeFromSuperlayer];
        }
    }
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    [cell.ms_featherBackgroundView layoutIfNeeded];
    CGRect bounds = cell.ms_featherBackgroundView.bounds;
    
    
    CGPoint tl = bounds.origin;
    CGPoint bl = CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height);
    
    CGPoint tr = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
    CGPoint br = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);

    if (indexPath.row == 0) {
        CGPoint points[] = {bl,tl,tr,br};
        CGPathAddLines(pathRef, nil, points, 4);
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPoint points[] = {tl,bl,br,tr};
        CGPathAddLines(pathRef, nil, points, 4);
    } else {
        CGPoint p1[] = {tl,bl};
        CGPathAddLines(pathRef, nil, p1, 2);
        
        CGPoint p2[] = {tr,br};
        CGPathAddLines(pathRef, nil, p2, 2);
    }
    
    layer.path = pathRef;
    layer.name = LAYERNAME;
    CFRelease(pathRef);
    layer.strokeColor = [SystemUtil colorFromHexString:@"#e2e2e2"].CGColor;
    layer.lineWidth = 1.0f;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    
    [cell.ms_featherBackgroundView.layer insertSublayer:layer atIndex:0];
}


@end

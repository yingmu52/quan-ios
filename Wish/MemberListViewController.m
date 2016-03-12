//
//  MemberListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-09.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MemberListViewController.h"
#import "Theme.h"
#import "MemberListCell.h"
#import "UIImageView+ImageCache.h"
@interface MemberListViewController ()

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationItem];
    [self.fetchCenter getMemberListForCircle:self.circle completion:^(NSArray *memberIDs) {
        NSLog(@"%@",memberIDs);
        self.tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
        self.tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"ownerId = %@ OR ownerId IN %@",self.circle.ownerId,memberIDs];
        self.tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ownerId" ascending:NO]];
        [self.tableView reloadData];
    }];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // clear empty cell
    
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
    
    //Right Bar Button

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[Theme navInviteDefault]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:nil];
    
    //Title
    self.navigationItem.title = @"管理成员";
}

//- (NSFetchRequest *)tableFetchRequest{
//    if (!_tableFetchRequest) {
//        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
//        _tableFetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY circles.circleId = %@",self.circle.circleId];
//        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ownerName" ascending:NO]];
//    }
//    return _tableFetchRequest;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Owner *owner = [self.tableFetchedRC objectAtIndexPath:indexPath];
    
    NSString *identifier = [self.circle.ownerId isEqualToString:owner.ownerId] ? @"MemberListCellAdmin" : @"MemberListCellNormal";
    MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if ([self.circle.ownerId isEqualToString:owner.ownerId]) {
        cell.iconImageView.image = [Theme circleOwnerIcon];
    }
    cell.nameLabel.text = owner.ownerName;

    [cell.headImageView downloadImageWithImageId:owner.headUrl
                                            size:FetchCenterImageSize100];

    return cell;
}



@end

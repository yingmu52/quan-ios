//
//  CirclePickerViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2016-03-25.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "CirclePickerViewController.h"
#import "Theme.h"
#import "CircleListCell.h"
#import "UIImageView+ImageCache.h"
@interface CirclePickerViewController ()

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

//- (NSFetchRequest *)tableFetchRequest{
//    if (!_tableFetchRequest) {
//        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Circle"];
//        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
//    }
//    return _tableFetchRequest;
//}


- (CircleListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CircleListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CirclePickerCell"];
    [self configureTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    CircleListCell *c = (CircleListCell *)cell;
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    c.circleListTitle.text = circle.circleName;
    c.circleListSubtitle.text = circle.circleDescription;
    [c.circleListImageView downloadImageWithImageId:circle.imageId
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

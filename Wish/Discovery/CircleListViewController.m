//
//  CircleListViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-20.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import "CircleListViewController.h"
#import "Theme.h"
@interface CircleListViewController () <UITableViewDelegate>
@end

@implementation CircleListViewController

- (void)viewDidLoad{
    
    //设置导航项目
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:CGRectMake(0, 0, 25, 25)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    //清除空白的Cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    //请求圈子列表
    [self.fetchCenter getCircleList:^(NSArray *circles){}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleListCell"];
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    cell.textLabel.text = circle.circleName;
    
    UIImage *image = [[User currentCircleId] isEqualToString:circle.circleId] ? [Theme circleListCheckBoxSelected] : [Theme circleListCheckBoxDefault];
    cell.accessoryView = [[UIImageView alloc] initWithImage:image];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Circle *circle = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if (![[User currentCircleId] isEqualToString:circle.circleId]) { //当选择了与当前不同的圈子时才执行操作
        [self.fetchCenter switchToCircle:circle.circleId completion:^{ //请求换圈
            [User updateAttributeFromDictionary:@{CURRENT_CIRCLE_ID:circle.circleId}]; //缓存圈子id
            [self.navigationController popViewControllerAnimated:YES]; //返回
        }];
    }
}

#pragma mark - Override Methods
- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Circle"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]];
    }
    return _tableFetchRequest;
}


@end

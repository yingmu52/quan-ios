//
//  TaskViewController.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "TaskViewController.h"
#import "Task+CoreDataClass.h"
#import "SystemUtil.h"
#import "MSRocketStation.h"
@interface TaskViewController ()

@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"任何列表";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(start)];
    
}

- (void)start{
    [[MSRocketStation sharedStation] removeAllFinishedTasks];
}

- (NSFetchRequest *)tableFetchRequest{
    if (!_tableFetchRequest) {
        _tableFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
        _tableFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mCreateTime" ascending:NO]];
        [_tableFetchRequest setFetchBatchSize:3];
    }
    return _tableFetchRequest;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OfflineTaskCell" forIndexPath:indexPath];
    Task *task = [self.tableFetchedRC objectAtIndexPath:indexPath];
    if (task.isFinished.boolValue) {
        cell.textLabel.text = [NSString stringWithFormat:@"【已完成】标题：%@",task.mTitle];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"标题：%@",task.mTitle];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"创建于：%@，事件ID：%@",[SystemUtil stringFromDate:task.mCreateTime],task.planID];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68.0f;
}

@end

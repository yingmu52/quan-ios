
//  WishDetailOwnerAchieved.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-27.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCOwnerAchieved.h"
@interface WishDetailVCOwnerAchieved ()

@end

@implementation WishDetailVCOwnerAchieved



- (void)setUpNavigationItem{
    [super setUpNavigationItem];
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *deleteBtn = [Theme buttonWithImage:[Theme navButtonDeleted]
                                           target:self
                                         selector:@selector(deletePlan)
                                            frame:frame];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
}

-(void)deletePlan{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除的事件不恢复哦！"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  //执行删除操作
                                  [self.plan deleteSelf];
                                  [self.navigationController popViewControllerAnimated:YES];
                              }];
    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    

}

- (NSString *)segueForFeed{
    return @"ShowFeedFromAchievementDetail";
}
@end

//
//  FeedDetailVCOwner.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-06-13.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FeedDetailVCOwner.h"

@interface FeedDetailVCOwner ()

@end

@implementation FeedDetailVCOwner

- (void)setUpNavigationItem
{
    
    CGRect frame = CGRectMake(0,0, 25,25);
    UIButton *backBtn = [Theme buttonWithImage:[Theme navBackButtonDefault]
                                        target:self.navigationController
                                      selector:@selector(popViewControllerAnimated:)
                                         frame:frame];
    
    
    UIButton *shareButton = [Theme buttonWithImage:[Theme navShareButtonDefault]
                                            target:self
                                          selector:nil
                                             frame:frame];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    UIButton *deleteButton = [Theme buttonWithImage:[Theme navButtonDeleted]
                                             target:self
                                           selector:@selector(showPopupView)
                                              frame:frame];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil action:nil];
    space.width = 25.0f;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:deleteButton],
                                                space,
                                                [[UIBarButtonItem alloc] initWithCustomView:shareButton]];
    
}

#pragma mark - feed deletion

- (void)showPopupView{
    if (self.feed){
        NSString *title = [self isDeletingTheLastFeed] ?
        @"这是最后一条记录啦！\n这件事儿也会被删除哦~" : @"真的要删除这条记录吗？";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            if ([self isDeletingTheLastFeed]){
                                                                [self.feed.plan deleteSelf];
                                                                [self.navigationController popToRootViewControllerAnimated:YES];
                                                            }else{
                                                                [self.fetchCenter deleteFeed:self.feed completion:^{
                                                                    [self.feed deleteSelf];
                                                                    [self.navigationController popViewControllerAnimated:YES];
                                                                }];
                                                            }
                                                        }];
        
        [alert addAction:confirm];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (BOOL)isDeletingTheLastFeed{
    return self.feed.plan.feeds.count == 1;
}

@end

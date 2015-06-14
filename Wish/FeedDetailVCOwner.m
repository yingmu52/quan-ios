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
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        NSString *popupViewTitle = [self isDeletingTheLastFeed] ?
        @"这是最后一条记录啦！\n这件事儿也会被删除哦~" : @"真的要删除这条记录吗？";
        PopupView *popupView = [PopupView showPopupDeleteinFrame:window.frame
                                                       withTitle:popupViewTitle];
        popupView.delegate = self;
        [window addSubview:popupView];
    }
}

- (void)popupViewDidPressCancel:(PopupView *)popupView{
    [popupView removeFromSuperview];
}

- (void)popupViewDidPressConfirm:(PopupView *)popupView{
    if ([self isDeletingTheLastFeed]){
        [self.feed.plan deleteSelf];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.fetchCenter deleteFeed:self.feed];
    }
    [self popupViewDidPressCancel:popupView];
}

- (void)didFinishDeletingFeed:(Feed *)feed{
    [feed deleteSelf];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isDeletingTheLastFeed{
    return self.feed.plan.feeds.count == 1;
}

@end

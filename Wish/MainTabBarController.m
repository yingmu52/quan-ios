//
//  MainTabBarController.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-08-15.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "MainTabBarController.h"
#import "SystemUtil.h"
#import "FetchCenter.h"
#import "Theme.h"
@interface MainTabBarController () <FetchCenterDelegate,UITabBarControllerDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSTimer *messageNotificationTimer;
@property (nonatomic) NSInteger numberOfMessages;
@property (nonatomic) BOOL shouldBark;
@end

@implementation MainTabBarController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //设置Tabar的高度
    CGRect tabFrame = self.tabBar.frame;
    CGFloat height = 60.0f;
    tabFrame.size.height = height;
    tabFrame.origin.y = self.view.frame.size.height - height;
    self.tabBar.frame = tabFrame;
    
    
    //设置中间的加号按扭
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [Theme tabbarAddButton];
    addButton.frame = CGRectMake(tabFrame.size.width * 0.5 - buttonImage.size.width * 0.5,
                                 tabFrame.size.height * 0.5 - buttonImage.size.height * 0.5,
                                 buttonImage.size.width,
                                 buttonImage.size.height);
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];

    [addButton addTarget:self
                  action:@selector(showShuffleView)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:addButton];

}

- (void)showShuffleView{
    if ([User isVisitor]) {
        [self showVisitorLoginAlert];
    }else{
        [self performSegueWithIdentifier:@"showShuffleViewFromTabbar" sender:nil];
    }
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    //设置字体大小
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]};
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];

    //设置选中项的颜色
    UIColor *color = [SystemUtil colorFromHexString:@"#32C9A9"];
    [[UITabBar appearance] setTintColor:color];

    //触发消息读取的时钟
    [self.messageNotificationTimer fire];
    
    //设置delegate，游客登陆态回调要用到
    self.delegate = self;
}
#pragma mark - observe message notification

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter){
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}

- (NSTimer *)messageNotificationTimer{
    if (!_messageNotificationTimer) {
        _messageNotificationTimer  = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(requestMessageCount) userInfo:nil repeats:YES];
    }
    return _messageNotificationTimer;
}

- (void)setNumberOfMessages:(NSInteger)numberOfMessages{
    UITabBarItem *messageTab;
    //找到消息项
    for (UITabBarItem *item in self.tabBar.items) {
        if ([item.title isEqualToString:@"消息"]) {
            messageTab = item;
        }
    }
    
    //设置项右上角的数字提示
    if (messageTab) {
        _numberOfMessages = numberOfMessages;
        if (numberOfMessages > 0) {
            
            //显示记数
            [messageTab setBadgeValue:[NSString stringWithFormat:@"%@",@(numberOfMessages)]];
            
        }else{ //隐蔽记数
            [messageTab setBadgeValue:nil];
        }
    }
}


- (void)requestMessageCount{
    if ([User isUserLogin]) {
        [self.fetchCenter getMessageNotificationInfo:^(NSNumber *messageCount, NSNumber *followCount) {
            self.numberOfMessages = messageCount.integerValue;
        }];
    }else{
        self.messageNotificationTimer = nil;
    }
}

- (void)dealloc{
    [self.messageNotificationTimer invalidate];
    self.messageNotificationTimer = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (tabBar.selectedItem == item) {
        [item setBadgeValue:nil];
    }
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (viewController != tabBarController.viewControllers.firstObject && [User isVisitor]) {
        [self showVisitorLoginAlert];
        return NO;
    }
    return YES;
}


- (void)showVisitorLoginAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录后才能使用更多的功能哦！"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"立即登录"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action)
                      {
                          [AppDelegate logout];
                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"稍等片刻" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end






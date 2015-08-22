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
@interface MainTabBarController () <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) NSTimer *messageNotificationTimer;
@property (nonatomic) NSInteger numberOfMessages;
@end

@implementation MainTabBarController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect tabFrame = self.tabBar.frame;
    CGFloat height = 60.0f;
    tabFrame.size.height = height;
    tabFrame.origin.y = self.view.frame.size.height - height;
    self.tabBar.frame = tabFrame;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    UIColor *color = [SystemUtil colorFromHexString:@"#32C9A9"];
    [[UITabBar appearance] setSelectedImageTintColor:color];
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

- (void)didFailSendingRequestWithInfo:(NSDictionary *)info entity:(NSManagedObject *)managedObject{
    //do nothing
}


- (void)setNumberOfMessages:(NSInteger)numberOfMessages{
    id messageTab = [self.tabBar.items objectAtIndex:2];
    _numberOfMessages = numberOfMessages;
    if (numberOfMessages > 0) { //显示记数
        [messageTab setBadgeValue:[NSString stringWithFormat:@"%@",@(numberOfMessages)]];
    }else{ //隐蔽记数
        [messageTab setBadgeValue:nil];
    }
}

- (void)didFinishGettingMessageNotificationWithMessageCount:(NSNumber *)msgCount followCount:(NSNumber *)followCount{
    NSLog(@"message count %@, follow count %@",msgCount,followCount);
#warning number of message doesn't include follow count
//    self.numberOfMessages = @(msgCount.integerValue + followCount.integerValue).integerValue;
    self.numberOfMessages = msgCount.integerValue;
}

- (void)requestMessageCount{
    if ([User isUserLogin]) {
        [self.fetchCenter getMessageNotificationInfo];
    }else{
        self.messageNotificationTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.messageNotificationTimer fire];
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

@end
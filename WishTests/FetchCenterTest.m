//
//  FetchCenterTest.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-17.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FetchCenter.h"
static NSTimeInterval expectationTimeout = 30.0f;
@interface FetchCenterTest : XCTestCase <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@property (nonatomic,strong) Plan *testPlan;
@end

@implementation FetchCenterTest

- (FetchCenter *)fetchCenter{
    if (!_fetchCenter) {
        _fetchCenter = [[FetchCenter alloc] init];
        _fetchCenter.delegate = self;
    }
    return _fetchCenter;
}
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testGetDiscoveryList{
    XCTestExpectation *expectation = [self expectationWithDescription:@"发现页事件列表拉取接口"];
    [self.fetchCenter getDiscoveryList:^(NSMutableArray *plans, NSString *circleTitle) {
        if (plans.count > 0 && circleTitle) {
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:expectationTimeout
                                 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error,@"发现页事件列表拉取错误");
    }];
}

- (void)testGetCircleList{
    XCTestExpectation *expectation = [self expectationWithDescription:@"圈子列表拉取接口"];
    [self.fetchCenter getCircleList:^(NSArray *circles) {
        if (circles.count > 0){
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:expectationTimeout
                                 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error,@"圈子列表拉取错误");
    }];
}

- (void)testSwitchToCircle{
    XCTAssert([User currentCircleId].length > 0,@"当前圈子id为空");
    XCTestExpectation *expectation = [self expectationWithDescription:@"切换圈子接口"];

    [self.fetchCenter getCircleList:^(NSArray *circles) {
        XCTAssert(circles.count > 0,@"圈子数量不能为0");

        //选取一个非当前圈子id（非当前圈子）
        NSArray *pool = [circles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"circleId != %@",[User currentCircleId]]];
        Circle *destinationCircle = pool.lastObject;

        if (destinationCircle.circleId) {
            [self.fetchCenter switchToCircle:destinationCircle.circleId completion:^{
                [expectation fulfill];
            }];
        }else{
            NSLog(@"获取的圈子列表 %@",[circles valueForKey:@"circleId"]);
            NSLog(@"目标切换圈子id: %@",destinationCircle.circleId);
            NSLog(@"当前圈子id: %@",[User currentCircleId]);
        }

    }];
    [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error,@"切换圈子接口错误");
        
    }];
}

- (void)testJointCircle{
    NSArray *codes = @[@"1001",@"1002",@"2001",@"2002"]; //诗歌，旅游，灌水，极品
    for (NSString *code in codes){
        XCTestExpectation *expectation = [self expectationWithDescription:@"加入圈子接口"];
        [self.fetchCenter joinCircle:code completion:^(NSString *circleId) {
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"加入圈子接口错误");
        }];
    }
}

- (void)testGetPlanList{
    XCTestExpectation *expectation = [self expectationWithDescription:@"事件列表拉取接口"];

    [self.fetchCenter getPlanListForOwnerId:[User uid] completion:^(NSArray *plans) {
        if (plans.count > 0) {
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:expectationTimeout
                                 handler:^(NSError * _Nullable error) {
                                     XCTAssertNil(error,@"事件列表拉取接口错误");
                                 }];

}

- (void)testLikeAndUnLikeFeed{
    NSArray *array = [Plan fetchWith:@"Feed" predicate:nil keyForDescriptor:@"createDate"];
    XCTAssertTrue(array.count > 0, @"本地没有缓存到feed");
    

    for (NSUInteger i = 0; i < 10; i ++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"赞与取消赞接口"];
        Feed *feed = array[i];
        NSInteger currentLikesStatic = feed.likeCount.integerValue;
        __block NSInteger currentLikesDynamic = currentLikesStatic;
        
        [self.fetchCenter likeFeed:feed completion:^{
            currentLikesDynamic += 1;
            [self.fetchCenter unLikeFeed:feed completion:^{
                currentLikesDynamic -= 1;
                [expectation fulfill];
            }];
        }];
        
        XCTAssertTrue(currentLikesDynamic == currentLikesStatic,@"赞与非赞的执行次数不一致");
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"赞与取消赞接口错误");
            if (error) {
                NSLog(@"%@",feed);
            }
        }];
    }
    

}

- (void)testUpdatePlan{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"planTitle = %@",@"PlanForUnitTesting"];
    NSArray *array = [Plan fetchWith:@"Plan" predicate:predicate keyForDescriptor:@"createDate"];
    XCTAssertTrue(array.count == 1, @"事件不存在");

    Plan *plan = array.lastObject;
    NSUInteger numberOfCycles = 100;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        plan.detailText = [NSUUID UUID].UUIDString; //修改事件描述
        plan.planStatus = i == numberOfCycles ? @(PlanStatusOnGoing) : @(PlanStatusFinished); //修改事件状态
        XCTestExpectation *expectation = [self expectationWithDescription:@"更新事件内容接口"];
        [self.fetchCenter updatePlan:plan completion:^{
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"更新事件内容接口错误");
            if (error) {
                NSLog(@"%@",plan);
            }
        }];
    }
    [plan.managedObjectContext save:nil];

}


#define testPlanTitle @"PlanForUnitTesting"

- (Plan *)testPlan{
    if (!_testPlan) {
        NSArray *array = [Plan fetchWith:@"Plan"
                               predicate:[NSPredicate predicateWithFormat:@"planTitle = %@",testPlanTitle]
                        keyForDescriptor:@"planTitle"];
        XCTAssertFalse(array.count == 0,@"找不到测试事件");
        _testPlan = array.lastObject;
    }
    XCTAssertNotNil(_testPlan,@"Null事件");
    return _testPlan;
}

- (void)testUpdatePlanStatus{
    NSUInteger numberOfCycles = 10;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        self.testPlan.detailText = [NSUUID UUID].UUIDString; //修改事件描述
        PlanStatus status  =  [self.testPlan.planStatus isEqualToNumber:@(PlanStatusFinished)] ? PlanStatusOnGoing : PlanStatusFinished; //修改事件状态
        [self.testPlan updatePlanStatus:status];
        XCTestExpectation *expectation = [self expectationWithDescription:@"更新事件状态接口"];
        [self.fetchCenter updateStatus:self.testPlan completion:^{
            [expectation fulfill];
        }];

        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"更新事件状态接口错误");
            if (error) {
                NSLog(@"%@",self.testPlan);
            }
        }];
    }
    [self.testPlan.managedObjectContext save:nil];
   
}

- (void)testCreateAndDeletePlan{
    NSUInteger numberOfCycles = 10;
    Plan *plan;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"事件创建与删除接口"];
        plan = [Plan createPlan:testPlanTitle privacy:YES];
        [self.fetchCenter uploadToCreatePlan:plan completion:^(Plan *plan) {
            XCTAssertTrue(plan.planId,@"事件没有缓存后台传来的id");
            [self.fetchCenter postToDeletePlan:plan completion:^{
                [plan.managedObjectContext deleteObject:plan];
                [expectation fulfill];
            }];
        }];
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"事件创建与删除错误");
            if (error) {
                NSLog(@"%@",plan);
            }
        }];
    }
    [plan.managedObjectContext save:nil];
}


- (void)testCreateAndDeleteFeed{

    NSUInteger numberOfCycles = 10;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        NSArray *imageIds = @[@"bg1",@"bg2",@"bg3"];
        Feed *feed = [Feed createFeedInPlan:self.testPlan feedTitle:@"testFeedTitle"];
        
        XCTestExpectation *expectation = [self expectationWithDescription:@"创建与删除Feed接口"];
        [self.fetchCenter uploadToCreateFeed:feed fetchedImageIds:imageIds completion:^(Feed *feed) {
            XCTAssertTrue(feed.feedId,@"从后台获取Feed id失败");
            [self.fetchCenter deleteFeed:feed completion:^{ //这个请求处理了对Feed的删除操作
                [feed deleteSelf];
                [expectation fulfill];
            }];
            
        }];
        
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"创建与删除Feed接口错误");
            if (error) {
                NSLog(@"%@",feed);
            }
        }];   
    }
}

- (void)testFollowAndUnfollowPlan{
    NSUInteger numberOfCycles = 10;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"关注与取消关注事件接口"];
        [self.fetchCenter followPlan:self.testPlan completion:^{
            [self.fetchCenter unFollowPlan:self.testPlan completion:^{
                [expectation fulfill];
            }];
        }];
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"关注与取消关注事件接口错误");
        }];
    }
}

- (void)testGetFollowingPlanList{
    XCTestExpectation *expectation = [self expectationWithDescription:@"关注事件列表拉取接口"];
    
    [self.fetchCenter getFollowingPlanList:^(NSArray *planIds) {
        if (planIds) {
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:expectationTimeout
                                 handler:^(NSError * _Nullable error) {
                                     XCTAssertNil(error,@"关注事件列表拉取接口错误");
                                 }];
    
}

- (void)testCheckNewVersion{
    
    for (NSInteger i = 0 ; i < 100; i ++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"新版本提示接口"];
        
        [self.fetchCenter checkVersion:^(BOOL hasNewVersion) {
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:expectationTimeout
                                     handler:^(NSError * _Nullable error) {
                                         XCTAssertNil(error,@"新版本提示接口错误");
                                     }];
    }
    
}

- (void)testSendingFeedBack{
    for (NSInteger i = 0 ; i < 100; i ++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"反馈接口"];
        NSString *content = [NSString stringWithFormat:@"测试%@",@(i)];
        [self.fetchCenter sendFeedback:content content:content completion:^{
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:expectationTimeout
                                     handler:^(NSError * _Nullable error) {
                                         XCTAssertNil(error,@"反馈接口错误");
                                     }];
    }
}
@end









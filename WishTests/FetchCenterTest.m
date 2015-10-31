//
//  FetchCenterTest.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-17.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FetchCenter.h"
static NSTimeInterval expectationTimeout = 5.0;
@interface FetchCenterTest : XCTestCase <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
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

- (void)testUpdatePlanStatus{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"planTitle = %@",@"PlanForUnitTesting"];
    NSArray *array = [Plan fetchWith:@"Plan" predicate:predicate keyForDescriptor:@"createDate"];
    XCTAssertTrue(array.count == 1, @"事件不存在");
    
    Plan *plan = array.lastObject;
    NSUInteger numberOfCycles = 10;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        plan.detailText = [NSUUID UUID].UUIDString; //修改事件描述
        PlanStatus status  =  [plan.planStatus isEqualToNumber:@(PlanStatusFinished)] ? PlanStatusOnGoing : PlanStatusFinished; //修改事件状态
        [plan updatePlanStatus:status];
        XCTestExpectation *expectation = [self expectationWithDescription:@"更新事件状态接口"];
        [self.fetchCenter updateStatus:plan completion:^{
            [expectation fulfill];
        }];

        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"更新事件状态接口错误");
            if (error) {
                NSLog(@"%@",plan);
            }
        }];
    }
    [plan.managedObjectContext save:nil];
   
}

- (void)testCreateAndDeletePlan{
    NSUInteger numberOfCycles = 10;
    for (NSInteger i = 0; i <= numberOfCycles; i++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"事件创建与删除接口"];
        Plan *plan = [Plan createPlan:@"testCreateAndDeletePlan" privacy:YES];
        [self.fetchCenter uploadToCreatePlan:plan completion:^(Plan *plan) {
            XCTAssertTrue(plan.planId,@"事件没有缓存后台传来的id");
            [self.fetchCenter postToDeletePlan:plan completion:^{
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
}

@end








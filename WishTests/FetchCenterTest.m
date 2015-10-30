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
    XCTestExpectation *expectation = [self expectationWithDescription:@"切换圈子接口正常"];

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
        XCTestExpectation *expectation = [self expectationWithDescription:@"加入圈子接口正常"];
        [self.fetchCenter joinCircle:code completion:^(NSString *circleId) {
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:expectationTimeout handler:^(NSError * _Nullable error) {
            XCTAssertNil(error,@"加入圈子接口错误");
        }];
    }
}

@end








//
//  FetchCenterTest.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-17.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FetchCenter.h"
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

- (void)testAll{
    NSLog(@"测试圈子列表");
    [self.fetchCenter getCircleList:^(NSArray *circles) {
        XCTAssertNotNil(circles,@"Null Circle List");
        XCTAssertTrue(circles.count > 0, @"Nothing in Circle List");
        
        NSLog(@"测试切换圈子");
        Circle *circle = circles.lastObject;
        [self.fetchCenter switchToCircle:circle.circleId completion:nil];
    }];
    
    NSLog(@"测试加入圈子");
    [self.fetchCenter joinCircle:@"1001" completion:nil];

}

@end








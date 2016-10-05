//
//  LocalDataTest.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-08.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <XCTest/XCTest.h>
@import CoreData;
#import "Plan.h"
#import "Feed.h"
#import "AppDelegate.h"
@interface LocalDataTest : XCTestCase

@end

@implementation LocalDataTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testPlanCover{ //测试事件封面与第一条Feed的图片是否匹配
    
    //1.读取所有事件
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plan"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"backgroundNum" ascending:NO]];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:[AppDelegate getContext]
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    //2.匹配事件封面与第一条feed的封面
    for (Plan *plan in frc.fetchedObjects) {
        //读取最新一条feed
        NSArray *feeds = [plan.feeds sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO]]];
        Feed *feed = feeds.firstObject;
        
        //图片id不能为空
        XCTAssertTrue(feed.mCoverImageId,@"Null imageid in feed id %@",feed.mUID);
        XCTAssertTrue(plan.mCoverImageId,@"Null backgroundNum in plan id %@",plan.mCoverImageId);
        
        //匹配
        if (![plan.mCoverImageId isEqualToString:feed.mCoverImageId]) {
            NSLog(@"Feed Cover : %@",feed.mCoverImageId);
            NSLog(@"Plan Cover : %@",feed.plan.mCoverImageId);
            XCTAssertTrue(NO,@"Mismatched Post Cover");
        }
    }
}

@end

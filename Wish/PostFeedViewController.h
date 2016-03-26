//
//  PostFeedViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "Plan.h"
#import "Circle.h"
@interface PostFeedViewController : UIViewController
@property (nonatomic,strong) Circle *circle;
@property (nonatomic,strong) Plan *plan;
@property (nonatomic,strong) NSMutableArray *assets;
@property (nonatomic) BOOL seugeFromPlanCreation;
@end

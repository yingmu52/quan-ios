//
//  PostFeedViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-02-12.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed+CoreDataClass.h"
#import "Plan+CoreDataClass.h"
#import "Circle+CoreDataClass.h"
#import "MSSuperViewController.h"

@interface PostFeedViewController : MSSuperViewController
@property (nonatomic,strong) Circle *circle;
@property (nonatomic,strong) Plan *plan;
@property (nonatomic,strong) NSMutableArray *assets;
@property (nonatomic) BOOL seugeFromPlanCreation;
@end

//
//  EditWishViewController.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-25.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan+CoreDataClass.h"
#import "MSSuperViewController.h"
@interface EditWishViewController : MSSuperViewController
@property (nonatomic,strong) Plan *plan;
@end

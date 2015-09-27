//
//  MSSuperViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-09-26.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchCenter.h"
@interface MSSuperViewController : UIViewController <FetchCenterDelegate>
@property (nonatomic,strong) FetchCenter *fetchCenter;
@end

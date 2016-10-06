//
//  FeedDetailViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-05-02.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed+CoreDataClass.h"
#import "Message+CoreDataClass.h"
#import "Theme.h"
#import "UIImageView+ImageCache.h"
#import "SDWebImageCompat.h"
#import "FeedDetailHeader.h"
#import "MSSuperViewController.h"

@interface FeedDetailViewController : MSSuperViewController <FeedDetailHeaderDelegate>

@property (nonatomic,strong) Message *message;
@property (nonatomic,strong) Feed *feed;

@end

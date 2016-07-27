//
//  InvitationViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-10-27.
//  Copyright © 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSuperViewController.h"

@interface InvitationViewController : MSSuperViewController
//@property (nonatomic,strong) Circle *circle;

@property (nonatomic,strong) NSURL *imageUrl;
@property (nonatomic,strong) NSString *h5Url;
@property (nonatomic,strong) NSString *titleText;
@property (nonatomic,strong) NSString *sharedContentTitle;
@property (nonatomic,strong) NSString *sharedContentDescription;
@end

//
//  LoginViewController.h
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h" //includes WXApiDelegate

@interface LoginViewController : UIViewController <WXApiDelegate>

+ (LoginViewController *)initLoginViewController;
@end

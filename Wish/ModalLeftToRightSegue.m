//
//  ModalLeftToRightSegue.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-03-28.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "ModalLeftToRightSegue.h"

@implementation ModalLeftToRightSegue

- (void)perform{
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        // Assign the source and destination views to local variables.
        UIView* firstVCView = sourceViewController.view;
        UIView* secondVCView = destinationController.view;
        
        // Get the screen width and height.
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        // Specify the initial position of the destination view.
        secondVCView.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight);
        
        // Access the app's key window and insert the destination view above the current (source) one.
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window insertSubview:secondVCView aboveSubview:firstVCView];
        
        // Animate the transition.
        [UIView animateWithDuration:0.25 animations:^{
            firstVCView.frame = CGRectOffset(firstVCView.frame,screenHeight,0.0f);
            secondVCView.frame = CGRectOffset(secondVCView.frame,screenHeight,0.0f);

        }completion:^(BOOL finished) {
            [sourceViewController presentViewController:destinationController animated:NO completion:nil];
        }];
    }else{
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        
        [destinationController.view.layer addAnimation:transition forKey:kCATransition];
        [sourceViewController presentViewController:destinationController animated:NO completion:nil];

    }

}
@end

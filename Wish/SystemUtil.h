//
//  SystemUtil.h
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "Reachability.h"
@interface SystemUtil : NSObject


+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
+ (NSString *)stringFromDate:(NSDate *)date;

+ (UIImagePickerController *)showCamera:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate;
+ (UIImage *)darkLayeredImage:(UIImage *)image inRect:(CGRect)bounds;

+ (void)setupShawdowForView:(UIView *)view;
+ (UIImage *)imageFromColor:(UIColor *)color;



@end

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
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)timeStringFromDate:(NSDate *)date;


+ (UIImagePickerController *)showCamera:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate;
+ (UIImage *)darkLayeredImage:(UIImage *)image inRect:(CGRect)bounds;

+ (void)setupShawdowForView:(UIView *)view;
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
+ (CGFloat)heightForText:(NSString *)text withFontSize:(CGFloat)size;
+ (NSString *)randomLorumIpsum;

@end

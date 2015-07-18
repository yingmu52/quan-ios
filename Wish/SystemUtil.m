//
//  SystemUtil.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "SystemUtil.h"
#import "UIImage+ImageEffects.h"
@implementation SystemUtil


// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    
    NSInteger days = [components day]+1;
    return days <= 0 ? 1 : days;
}





+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [formatter stringFromDate:date];
}

+ (NSString *)timeStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:date];
}

+ (UIImagePickerController *)showCamera:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate{
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return nil;
    }
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.allowsEditing = YES;
    controller.showsCameraControls = YES;
    controller.delegate = delegate;
    return controller;
}


+ (UIImage *)darkLayeredImage:(UIImage *)image inRect:(CGRect)bounds{
    
    UIImage *tileImage;
    
    CGSize size = bounds.size;
    UIGraphicsBeginImageContext(size);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();

    CGContextDrawTiledImage(imageContext, (CGRect){CGPointZero,size}, image.CGImage);

    //draw dark layer
    CGLayerRef aboveLayer = CGLayerCreateWithContext (imageContext, size, NULL);
    UIColor *darkLayerColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    CGContextSetFillColorWithColor(imageContext, darkLayerColor.CGColor);
    CGContextFillRect (imageContext, bounds);
    CGContextDrawLayerInRect (imageContext, bounds, aboveLayer);
    CGLayerRelease (aboveLayer);

    tileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tileImage;

}

+ (void)setupShawdowForView:(UIView *)view{
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowRadius = 1.0f;
    view.layer.shadowOpacity = 0.15f;
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}


+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#define kAvatarSize 40.0f
+ (CGFloat)heightForText:(NSString *)text withFontSize:(CGFloat)size{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:size],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(width - kAvatarSize,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
    return CGRectGetHeight(bounds);
}

@end

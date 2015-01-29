//
//  SystemUtil.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-24.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "SystemUtil.h"

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
    return [components day]+1;
}


#define OWNERID @"MOTHERFUCKING_OWNER_FUCKING_I_FUCKING_D"

#pragma mark - user id
+ (NSString *)getOwnerId{
#warning fucking change this in the future man !
    NSString *ownerID = [[NSUserDefaults standardUserDefaults] objectForKey:OWNERID];
    ownerID = ownerID ? ownerID : @"100001";
    return ownerID;
}

+ (void)updateOwnerId:(NSString *)newID
{
    return [[NSUserDefaults standardUserDefaults] setObject:newID forKey:OWNERID];
}


+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
#warning time zone?
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}


+ (BOOL)hasActiveInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return reachability.currentReachabilityStatus != NotReachable;
}


+ (UIImagePickerController *)showCamera:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate{
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return nil;
    }
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    controller.allowsEditing = YES;
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
    UIColor *darkLayerColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    CGContextSetFillColorWithColor(imageContext, darkLayerColor.CGColor);
    CGContextFillRect (imageContext, bounds);
    CGContextDrawLayerInRect (imageContext, bounds, aboveLayer);
    CGLayerRelease (aboveLayer);

    tileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tileImage;

}

@end

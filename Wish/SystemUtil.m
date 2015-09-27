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


+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectZero;
    rect.size = size;
    UIGraphicsBeginImageContext(size);
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


+ (NSString *)randomLorumIpsum {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales. Vestibulum ut est id mauris ultrices gravida. Nulla malesuada metus ut erat malesuada, vitae ornare neque semper. Aenean a commodo justo, vel placerat odio. Curabitur vitae consequat tortor. Aenean eu magna ante. Integer tristique elit ac augue laoreet, eget pulvinar lacus dictum. Cras eleifend lacus eget pharetra elementum. Etiam fermentum eu felis eu tristique. Integer eu purus vitae turpis blandit consectetur. Nulla facilisi. Praesent bibendum massa eu metus pulvinar, quis tristique nunc commodo. Ut varius aliquam elit, a tincidunt elit aliquam non. Nunc ac leo purus. Proin condimentum placerat ligula, at tristique neque scelerisque ut. Suspendisse ut congue enim. Integer id sem nisl. Nam dignissim, lectus et dictum sollicitudin, libero augue ullamcorper justo, nec consectetur dolor arcu sed justo. Proin rutrum pharetra lectus, vel gravida ante venenatis sed. Mauris lacinia urna vehicula felis aliquet venenatis. Suspendisse non pretium sapien. Proin id dolor ultricies, dictum augue non, euismod ante. Vivamus et luctus augue, a luctus mi. Maecenas sit amet felis in magna vestibulum viverra vel ut est. Suspendisse potenti. Morbi nec odio pretium lacus laoreet volutpat sit amet at ipsum. Etiam pretium purus vitae tortor auctor, quis cursus metus vehicula. Integer ultricies facilisis arcu, non congue orci pharetra quis. Vivamus pulvinar ligula neque, et vehicula ipsum euismod quis.";
    
    // Split lorum ipsum words into an array
    //
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    // Randomly choose words for variable length
    //
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(3, r); // no less than 3 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    // Array to string. Adding '!!!' to end of string to ensure all text is visible.
    //
    return [NSString stringWithFormat:@"%@!!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
    
}

@end

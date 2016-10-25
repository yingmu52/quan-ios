//
//  MSWXShareManager.h
//  Stories
//
//  Created by Xinyi Zhuang on 10/24/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSWXShareManager : NSObject

+ (void)share:(NSString *)title description:(NSString *)desc imageURL:(NSURL *)imageUrl h5url:(NSString *)h5url;
@end

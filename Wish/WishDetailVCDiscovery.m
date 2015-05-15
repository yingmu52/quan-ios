//
//  WishDetailVCDiscovery.m
//  Stories
//
//  Created by Xinyi Zhuang on 2015-04-06.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "WishDetailVCDiscovery.h"
#import "UIImageView+WebCache.h"
#import "Feed.h"
#import "User.h"
@interface WishDetailVCDiscovery ()
@end
@implementation WishDetailVCDiscovery


//- (void)dealloc{
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    for (Feed *feed in self.fetchedRC.fetchedObjects){
//        if (![feed.plan.ownerId isEqualToString:[User uid]]) {
//            [delegate.managedObjectContext deleteObject:feed];
//        }
//    }
//    [delegate saveContext];
//}

- (NSString *)segueForFeed{
    return @"showDiscoverFeedDetail";
}
@end






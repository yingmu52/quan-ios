//
//  MSBase.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/1/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase.h"

@implementation MSBase

+ (NSString *)ms_GetClassName{
    return NSStringFromClass([self class]);
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
         inManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[MSBase ms_GetClassName]];
    request.predicate = predicate;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mLastReadTime" ascending:YES]];
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

+ (id)fetchID:(NSString *)entityID inManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[MSBase ms_GetClassName]];
    request.predicate = [NSPredicate predicateWithFormat:@"mUID == %@",entityID];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mUID" ascending:YES]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSAssert(results.count <= 1, @"Fetching Duplicated Entity");
    return results.lastObject;
}

@end

//
//  MSBase+CoreDataClass.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/6/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase+CoreDataClass.h"

@implementation MSBase


+ (NSString *)ms_GetClassName{
    return NSStringFromClass([self class]);
}

+ (NSArray *)fetchWithPredicate:(nullable NSPredicate *)predicate
         inManagedObjectContext:(NSManagedObjectContext *)context{
    return [[self class] fetchWithPredicate:predicate WithKey:@"mUID" inManagedObjectContext:context];
}

+ (NSArray *)fetchWithPredicate:(nullable NSPredicate *)predicate
                        WithKey:(NSString *)key
         inManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[MSBase ms_GetClassName]];
    request.predicate = predicate;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:key ascending:YES]];
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}



+ (instancetype)fetchID:(NSString *)entityID inManagedObjectContext:(NSManagedObjectContext *)context{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mUID == %@",entityID];
    NSArray *results = [[self class] fetchWithPredicate:predicate WithKey:@"mUID" inManagedObjectContext:context];
    NSAssert(results.count <= 1, @"Fetching Duplicated Entity");
    return results.lastObject;
}



@end

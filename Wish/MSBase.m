//
//  MSBase.m
//  Stories
//
//  Created by Xinyi Zhuang on 10/1/16.
//  Copyright © 2016 Xinyi Zhuang. All rights reserved.
//

#import "MSBase.h"

@implementation MSBase

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
         inManagedObjectContext:(NSManagedObjectContext *)context{
    NSString *entityName = [NSString stringWithFormat:@"%@",[[self new] class]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastReadTime" ascending:YES]];
    NSError *error = nil;
    return [context executeFetchRequest:request error:&error];
}

+ (id)fetchID:(NSString *)entityID inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSString *entityName = NSStringFromClass([self class]);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"mUID == %@",entityID];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"mUID" ascending:YES]];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSAssert(results.count <= 1, @"Fetching Duplicated Entity");
    return results.lastObject;
}

@end

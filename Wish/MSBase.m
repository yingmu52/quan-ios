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
@end

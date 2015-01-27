//
//  MagicalRecord+delete.m
//  mage-ios-sdk
//
//  Created by William Newman on 12/15/14.
//  Copyright (c) 2014 National Geospatial-Intelligence Agency. All rights reserved.
//

#import "MagicalRecord+delete.h"

@implementation MagicalRecord (delete)

+(void) deleteCoreDataStack {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    [context lock];
    [context reset];
    NSArray *stores = [[NSPersistentStoreCoordinator MR_defaultStoreCoordinator] persistentStores];
    for(NSPersistentStore *store in stores) {
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator: nil];
    [context unlock];
    [self cleanUp];
}

@end

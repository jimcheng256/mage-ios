//
//  User.h
//  mage-ios-sdk
//
//  Created by William Newman on 4/22/15.
//  Copyright (c) 2015 National Geospatial-Intelligence Agency. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Observation, Team;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSNumber * currentUser;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) id recentEventIds;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Observation *observations;
@property (nonatomic, retain) NSSet *teams;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTeamsObject:(Team *)value;
- (void)removeTeamsObject:(Team *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end

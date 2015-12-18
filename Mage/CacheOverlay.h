//
//  CacheOverlay.h
//  MAGE
//
//  Created by Brian Osborn on 12/17/15.
//  Copyright © 2015 National Geospatial Intelligence Agency. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheOverlayTypes.h"

/**
 *  Abstract cache overlay
 */
@interface CacheOverlay : NSObject

/**
 *  True when enabled
 */
@property (nonatomic) BOOL enabled;

/**
 *  Initializer
 *
 *  @param name              name
 *  @param type              cache type
 *  @param supportsChildrens true if cache overlay with children caches
 *
 *  @return new instance
 */
-(instancetype) initWithName: (NSString *) name andType: (enum CacheOverlayType) type andSupportsChildren: (BOOL) supportsChildrens;

/**
 *  Constructor
 *
 *  @param name              name
 *  @param cacheName         cache name
 *  @param type              cache type
 *  @param supportsChildrens true if cache overlay with children caches
 *
 *  @return new instance
 */
-(instancetype) initWithName: (NSString *) name andCacheName: (NSString *) cacheName andType: (enum CacheOverlayType) type andSupportsChildren: (BOOL) supportsChildrens;

/**
 *  Get the name
 *
 *  @return name
 */
-(NSString *) getName;

/**
 *  Get the cache name
 *
 *  @return cache name
 */
-(NSString *) getCacheName;

/**
 *  Get the cache overlay type
 *
 *  @return cache overlay type
 */
-(enum CacheOverlayType) getType;

/**
 *  Determine if the cache overlay supports children
 *
 *  @return true if supports children
 */
-(BOOL) getSupportsChildren;

/**
 *  Get the children cache overlays
 *
 *  @return children cache overlays
 */
-(NSArray<CacheOverlay *> *) getChildren;

/**
 *  Get information about the cache to display
 *
 *  @return cache overlay info
 */
-(NSString *) getInfo;

/**
 *  Build the cache name of a child
 *
 *  @param name      cache name
 *  @param childName child cache name
 *
 *  @return child cache name
 */
+(NSString *) buildChildCacheNameWithName: (NSString *) name andChildName: (NSString *) childName;

@end

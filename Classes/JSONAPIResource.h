//
//  JSONAPIResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResource : NSObject<NSCopying, NSCoding>

@property (nonatomic, strong) id ID;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSDictionary *links;

@property (nonatomic, readonly) NSDictionary *mapKeysToProperties;

+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked;
+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass;

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked;
+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass;

- (id)initWithDictionary:(NSDictionary*)dict withLinked:(NSDictionary*)linked;

- (id)objectForKey:(NSString*)key;
- (id)linkedResourceForKey:(NSString*)key;

- (void)linkLinks:(NSDictionary*)linked;

- (BOOL)isEqualToJSONAPIResource:(JSONAPIResource *)jsonApiResource;

@end

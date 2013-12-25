//
//  JSONAPIResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResource : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSDictionary *links;

+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked;
+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass;

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked;
+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass;

- (id)objectForKey:(NSString*)key;
- (id)linkedResourceForKey:(NSString*)key;

@end

//
//  JSONAPITopLevel.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPI.h"

@interface JSONAPI()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation JSONAPI

#pragma mark - Class

+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary {
    return [[JSONAPI alloc] initWithDictionary:dictionary];
}

+ (instancetype)jsonAPIWithString:(NSString *)string {
    return [[JSONAPI alloc] initWithString:string];
}

#pragma mark - Instance

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        [self inflateWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithString:(NSString*)string {
    self = [super init];
    if (self) {
        [self inflateWithString:string];
    }
    return self;
}

- (void)inflateWithString:(NSString*)string {
    id json = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]] == YES) {
        [self inflateWithDictionary:json];
    } else {
        _internalError = [NSError errorWithDomain:@"Could not parse JSON" code:0 userInfo:nil];
    }
}

#pragma mark - Resources

- (id)resource {
    return _resources.firstObject;
}

//- (id)objectForKey:(NSString*)key {
//    return [_dictionary objectForKey:key];
//}

//- (id)resource {
//    NSString *key = @"data";
//    if ([key isEqualToString:@"meta"] == YES || [key isEqualToString:@"linked"] == YES) {
//        return nil;
//    }
//    
//    NSDictionary *rawResource = [_dictionary objectForKey:key];
//    JSONAPIResource *resource = nil;
//    if ([rawResource isKindOfClass:[NSDictionary class]] == YES) {
//        resource = [JSONAPIResource jsonAPIResource:rawResource withLinked:self.linked];
//    }
//    
//    // Fall back to first element in array
//    if (resource == nil) {
//        id resources = [self resources];
//        if ([resources isKindOfClass:[NSArray class]] == YES) {
//            return [resources firstObject];
//        }
//    }
//    
//    return resource;
//
//}

//- (NSArray*)resources {
//    NSString *key = @"data";
//    if ([key isEqualToString:@"meta"] == YES || [key isEqualToString:@"linked"] == YES) {
//        return nil;
//    }
//    
//    NSArray *rawResources = [_dictionary objectForKey:key];
//    NSArray *resources = nil;
//    if ([rawResources isKindOfClass:[NSArray class]] == YES) {
//        resources = [JSONAPIResource jsonAPIResources:rawResources withLinked:self.linked];
//    }
//    
//    return resources;
//}

#pragma mark - Private

- (void)inflateWithDictionary:(NSDictionary*)dictionary {
    
    // Sets internal dictionary
    _dictionary = dictionary;
    
    // Sets meta
    _meta = dictionary[@"meta"];
    if ([_meta isKindOfClass:[NSDictionary class]] == NO) {
        _meta = nil;
    }
    
    // Parse resources
    _data = _dictionary[@"data"];
    
    NSMutableArray *resources = @[].mutableCopy;
    if ([_data isKindOfClass:[NSArray class]] == YES) {
        
        NSArray *dataArray = (NSArray*) _data;
        for (NSDictionary *data in dataArray) {
            id resource = [self inflateResourceData:data];
            if (resource) [resources addObject:resource];
        }
        
    } else if ([_data isKindOfClass:[NSDictionary class]] == YES) {
        id resource = [self inflateResourceData:_data];
        if (resource) [resources addObject:resource];
    }
    _resources = resources;

//    // Sets linked
//    NSMutableDictionary *creatingLinked = [NSMutableDictionary dictionary];
//    NSDictionary *rawLinked = [dictionary objectForKey:@"linked"];
//    if ([rawLinked isKindOfClass:[NSArray class]] == YES) {
//        
//        NSMutableArray *linkedToLinkWithLinked = [NSMutableArray array];
//        
//        // Loops through linked arrays
//        for (NSDictionary *resourceDictionary in rawLinked) {
//            
//            NSString *type = resourceDictionary[@"type"];
//            NSMutableDictionary *resources = creatingLinked[type] ?: @{}.mutableCopy;
//            [creatingLinked setObject:resources forKey:type];
//            
//            JSONAPIResource *resource = [JSONAPIResource jsonAPIResource:resourceDictionary withLinked:nil];
//            if (resource.ID != nil) {
//                [resources setObject:resource forKey:resource.ID];
//                [linkedToLinkWithLinked addObject:resource];
//            }
//            
//        }
//        
//        // Linked the linked
//        for (JSONAPIResource *resource in linkedToLinkWithLinked) {
//            [resource linkLinks:creatingLinked];
//        }
//        
//    }
//    
//    _linked = creatingLinked;
}

- (id)inflateResourceData:(NSDictionary*)data {
    return [JSONAPIResource jsonAPIResource:data];
}

@end

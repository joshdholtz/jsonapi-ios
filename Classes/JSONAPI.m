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

#pragma mark - Init

+ (id)JSONAPIWithString:(NSString*)string {
    return [[JSONAPI alloc] initWithString:string];
}

+ (id)JSONAPIWithDictionary:(NSDictionary*)dictionary {
    return [[JSONAPI alloc] initWithDictionary:dictionary];
}

- (id)initWithString:(NSString*)string {
    self = [super init];
    if (self) {
        [self inflateWithString:string];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        [self inflateWithDictionary:dictionary];
    }
    return self;
}

- (void)inflateWithString:(NSString*)string {
    id json = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    if ([json isKindOfClass:[NSDictionary class]] == YES) {
        [self inflateWithDictionary:json];
    } else {
        _error = [NSError errorWithDomain:@"Could not parse JSON" code:0 userInfo:nil];
    }
}

#pragma mark - Resources

- (id)objectForKey:(NSString*)key {
    return [_dictionary objectForKey:key];
}

- (id)resourceForKey:(NSString*)key {
    JSONAPIResource *resource;
    
    NSArray *resources = [self resourcesForKey:key];
    if (resources.count > 0) {
        return [resources objectAtIndex:0];
    }
    
    return resource;
}

- (NSArray*)resourcesForKey:(NSString*)key {
    if ([key isEqualToString:@"meta"] == YES || [key isEqualToString:@"linked"] == YES) {
        return nil;
    }
    
    NSArray *rawResources = [_dictionary objectForKey:key];
    NSArray *resources = nil;
    if ([rawResources isKindOfClass:[NSArray class]] == YES) {
        Class c = [JSONAPIResourceModeler resourceForLinkedType:[JSONAPIResourceLinker linkedType:key]];
        resources = [JSONAPIResource jsonAPIResources:rawResources withLinked:self.linked withClass:c];
    }
    
    return resources;
}

#pragma mark - Private

- (void)inflateWithDictionary:(NSDictionary*)dictionary {
    // Sets dictionary
    _dictionary = dictionary;
    
    // Sets meta
    _meta = [dictionary objectForKey:@"meta"];
    if ([_meta isKindOfClass:[NSDictionary class]] == NO) {
        _meta = nil;
    }
    
    // Sets linked
    NSMutableDictionary *creatingLinked = [NSMutableDictionary dictionary];
    NSDictionary *rawLinked = [dictionary objectForKey:@"linked"];
    if ([rawLinked isKindOfClass:[NSDictionary class]] == YES) {
        
        NSMutableArray *linkedToLinkWithLinked = [NSMutableArray array];
        
        // Loops through linked arrays
        for (NSString *key in rawLinked.allKeys) {
            NSArray *value = [rawLinked objectForKey:key];
            
            if ([value isKindOfClass:[NSArray class]] == YES) {
                NSMutableDictionary *resources = [NSMutableDictionary dictionary];
                for (NSDictionary *resourceDictionary in value) {
                    Class c = [JSONAPIResourceModeler resourceForLinkedType:[JSONAPIResourceLinker linkedType:key]];
                    JSONAPIResource *resource = [JSONAPIResource jsonAPIResource:resourceDictionary withLinked:nil withClass:c];
                    if (resource.ID != nil) {
                        [resources setObject:resource forKey:resource.ID];
                        [linkedToLinkWithLinked addObject:resource];
                    }
                }
                [creatingLinked setObject:resources forKey:key];
                
            }
            
        }
        
        // Linked the linked
        for (JSONAPIResource *resource in linkedToLinkWithLinked) {
            [resource linkLinks:creatingLinked];
        }
        
    }
    
    _linked = creatingLinked;
}

@end

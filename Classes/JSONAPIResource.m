//
//  JSONAPIResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

#import "JSONAPIResourceLinker.h"

#pragma mark - JSONAPIResource

@interface JSONAPIResource()

@property (nonatomic, strong) NSDictionary *__dictionary;
@property (nonatomic, strong) NSMutableDictionary *__resourceLinks;

@end

@implementation JSONAPIResource

+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked {
    return [JSONAPIResource jsonAPIResources:array withLinked:linked withClass:[self class]];
}

+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass {
    if (resourceObjectClass == nil) {
        resourceObjectClass = [self class];
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        [mutableArray addObject:[[resourceObjectClass alloc] initWithDictionary:dict withLinked:linked]];
    }
    
    return mutableArray;
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked {
    return [JSONAPIResource jsonAPIResource:dictionary withLinked:linked withClass:[self class]];
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass {
    if (resourceObjectClass == nil) {
        resourceObjectClass = [self class];
    }
    
    return [[resourceObjectClass alloc] initWithDictionary:dictionary withLinked:linked];
}

- (id)init {
    self = [super init];
    if (self) {
        self.__resourceLinks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict withLinked:(NSDictionary*)linked {
    self = [self init];
    if (self) {
        [self setWithDictionary:dict];
        [self linkLinks:linked];
        
        
        for (NSString *key in [self mapKeysToProperties]) {
            if ([key hasPrefix:@"links."] == YES) {
                
                NSString *propertyName = [[self mapKeysToProperties] objectForKey:key];
                NSString *linkedResource = [key stringByReplacingOccurrencesOfString:@"links." withString:@""];
                
                id resource = [self linkedResourceForKey:linkedResource];
                if (resource != nil) {
                    @try {
                        [self setValue:resource forKey:propertyName];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"JSONAPIResource Warning - %@", [exception description]);
                    }
                }
                
            }
        }
        
    }
    return self;
}

- (id)objectForKey:(NSString*)key {
    return [self.__dictionary objectForKey:key];
}

- (id)linkedResourceForKey:(NSString *)key {
    return [self.__resourceLinks objectForKey:key];
}

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] init];
}

- (void)setWithDictionary:(NSDictionary*)dict {
    self.__dictionary = dict;
    
    // Loops through all keys to map to propertiess
    NSDictionary *userMap = [self mapKeysToProperties];
    
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:userMap];
    [map addEntriesFromDictionary:@{
                                         @"id" : @"ID",
                                         @"href" : @"href",
                                         @"links" : @"links"
                                         }];
    
    for (NSString *key in [map allKeys]) {
        
        // Checks if the key to map is in the dictionary to map
        if ([dict objectForKey:key] != nil && [dict objectForKey:key] != [NSNull null]) {
            
            NSString *property = [map objectForKey:key];
            
            NSRange inflateRange = [property rangeOfString:@"."];
            NSRange formatRange = [property rangeOfString:@":"];
            
            @try {
                if (inflateRange.location != NSNotFound) {

                } else if (formatRange.location != NSNotFound) {
  
                } else {
                    [self setValue:[dict objectForKey:key] forKey:property ];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"JSONAPIResource Warning - %@", [exception description]);
            }
            
        } else {
            
        }
        
    }
}

- (void)linkLinks:(NSDictionary*)linked {
    // Loops through links of resources
    for (NSString *linkTypeUnmapped in self.links.allKeys) {
        
        NSString *linkType = [JSONAPIResourceLinker linkedType:linkTypeUnmapped];
        if (linkType == nil) {
            linkType = linkTypeUnmapped;
        }
        
        // Gets linked objects for the resource
        id linksTo = [self.links objectForKey:linkTypeUnmapped];
        if ([linksTo isKindOfClass:[NSNumber class]] == YES || [linksTo isKindOfClass:[NSString class]] == YES) {
            
            JSONAPIResource *linkedResource = [[linked objectForKey:linkType] objectForKey:linksTo];
            
            if (linkedResource != nil) {
                [self.__resourceLinks setObject:linkedResource forKey:linkTypeUnmapped];
            }
            
        } else if ([linksTo isKindOfClass:[NSArray class]] == YES) {
            NSMutableArray *linkedResources = [NSMutableArray array];
            [self.__resourceLinks setObject:linkedResources forKey:linkTypeUnmapped];
            for (id linkedId in linksTo) {
                JSONAPIResource *linkedResource = [[linked objectForKey:linkType] objectForKey:linkedId];
                if (linkedResource != nil) {
                    [linkedResources addObject:linkedResource];
                }
            }
            
        }
    }
}

@end

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
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        [mutableArray addObject:[[resourceObjectClass alloc] initWithDictionary:dict withLinked:linked]];
    }
    
    return mutableArray;
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked {
    return [[[self class] alloc] initWithDictionary:dictionary withLinked:linked];
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
        [self setWithLinks:linked];
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
//                    NSString *object = [property substringToIndex:inflateRange.location];
//                    property = [property substringFromIndex:(inflateRange.location+1)];
//                    
//                    Class class = NSClassFromString(object);
//                    if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
//                        ProtocolModel *obj = [[class alloc] initWithDictionary:[dict objectForKey:key]];
//                        [obj setParentModel:self];
//                        
//                        [self setValue:obj forKey:property];
//                    } else if ([[dict objectForKey:key] isKindOfClass:[NSArray class]]) {
//                        NSArray *array = [ProtocolModel protocolModels:[dict objectForKey:key] withClass:class];
//                        for (ProtocolModel *model in array) {
//                            [model setParentModel:self];
//                        }
//                        
//                        [self setValue:array forKey:property];
//                    }
                } else if (formatRange.location != NSNotFound) {
//                    NSString *formatFunction = [property substringToIndex:formatRange.location];
//                    property = [property substringFromIndex:(formatRange.location+1)];
//                    
//                    [self setValue:[[ProtocolModel sharedInstance] performFormatBlock:[dict objectForKey:key] withKey:formatFunction] forKey:property ];
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

- (void)setWithLinks:(NSDictionary*)linked {
    // Loops through links of resources
    for (NSString *linkTypeUnmapped in self.links.allKeys) {
        
        NSString *linkType = [JSONAPIResourceLinker linkedType:linkTypeUnmapped];
        if (linkType == nil) {
            linkType = linkTypeUnmapped;
        }
        
        // Gets linked objects for the resource
        id linksTo = [self.links objectForKey:linkTypeUnmapped];
        if ([linksTo isKindOfClass:[NSNumber class]] == YES) {
            JSONAPIResource *linkedResource = [[linked objectForKey:linkType] objectForKey:linksTo];
            
            [self.__resourceLinks setObject:linkedResource forKey:linkTypeUnmapped];
            
        } else if ([linksTo isKindOfClass:[NSArray class]] == YES) {
            NSMutableArray *linkedResources = [NSMutableArray array];
            [self.__resourceLinks setObject:linkedResources forKey:linkTypeUnmapped];
            for (NSNumber *linkedId in linksTo) {
                NSLog(@"Looking for linked object with ID of %@", linkedId);
                JSONAPIResource *linkedResource = [[linked objectForKey:linkType] objectForKey:linkedId];
                if (linkedResource != nil) {
                    [linkedResources addObject:linkedResource];
                }
            }
            
        }
    }
}

@end

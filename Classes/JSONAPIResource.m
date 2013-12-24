//
//  JSONAPIResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

@interface JSONAPIResource()

@property (nonatomic, strong) NSDictionary *__dictionary;

@end

@implementation JSONAPIResource

+ (NSArray*)jsonAPIResources:(NSArray*)array {
    return [JSONAPIResource jsonAPIResources:array withClass:[self class]];
}

+ (NSArray*)jsonAPIResources:(NSArray*)array withClass:(Class)resourceObjectClass {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        [mutableArray addObject:[[resourceObjectClass alloc] initWithDictionary:dict]];
    }
    
    return mutableArray;
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary {
    return [[[self class] alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary*)dict {
    self = [self init];
    if (self) {
        [self setWithDictionary:dict];
    }
    return self;
}

- (id)objectForKey:(NSString*)key {
    return [self.__dictionary objectForKey:key];
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

@end

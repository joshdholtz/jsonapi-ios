//
//  JSONAPIResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

#import "JSONAPI.h"
#import "JSONAPIResourceFormatter.h"
#import "JSONAPIResourceModeler.h"

#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - JSONAPIResource

@interface JSONAPIResource(){
    
    NSDictionary *_dictionary;
    NSMutableDictionary *_resourceLinks;
}


@end

@implementation JSONAPIResource

#pragma mark -
#pragma mark - Class Methods

+ (NSArray*)jsonAPIResources:(NSArray*)array {
    
    NSMutableArray *mutableArray = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        NSString *type = dict[@"type"] ?: @"";
        Class resourceObjectClass = [JSONAPIResourceModeler resourceForLinkedType:type];
        [mutableArray addObject:[[resourceObjectClass alloc] initWithDictionary:dict]];
    }
    
    return mutableArray;
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary {
    NSString *type = dictionary[@"type"] ?: @"";
    Class resourceObjectClass = [JSONAPIResourceModeler resourceForLinkedType:type];
    
    return [[resourceObjectClass alloc] initWithDictionary:dictionary];
}

#pragma mark -
#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        _resourceLinks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict {
    self = [self init];
    if (self) {
        [self setWithDictionary:dict];
    }
    return self;
}

- (id)objectForKey:(NSString*)key {
    return [_dictionary objectForKey:key];
}

- (id)linkedResourceForKey:(NSString *)key {
    return [_resourceLinks objectForKey:key];
}

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] init];
}

- (BOOL)setWithResource:(id)otherResource {
    if ([otherResource isKindOfClass:[self class]] == YES) {
        
        return YES;
    }
    
    return NO;
}

- (void)setWithDictionary:(NSDictionary*)dict {
    
    _dictionary = dict;
    
    //maps top level mandatory members of a JSONAPI Resource object
    NSDictionary *topLevelMembers = @{
                                      @"id" : @"ID",
                                      @"type" : @"type",
                                      };
    
    for(NSString *key in [topLevelMembers allKeys]){
        
        if ([dict objectForKey:key] != nil && [dict objectForKey:key] != [NSNull null]) {
            NSString *property = [topLevelMembers objectForKey:key];
            [self setValue:[dict objectForKey:key] forKey:property];
        }
        else{
            NSLog(@"JSONAPIResource Warning : key %@ not found in json data.\nyour JSONAPI Resource Object is not compliant to JSONAPI format, for further reading please refer to: http://jsonapi.org/format/#document-resource-objects", key);
        }
    }
    
    NSDictionary *resourceObjectAttributes = [dict objectForKey:@"attributes"];
    if(resourceObjectAttributes != nil && [dict objectForKey:@"attributes"] != [NSNull null]){
        
        self.attributes = resourceObjectAttributes;
        
        // Loops through all keys to map JSONAPI Resource Object attributes to Objective-C Properties
        
        NSDictionary *userMap = [self mapKeysToProperties];
        if(userMap){
            
            for (NSString *key in [userMap allKeys]) {
                
                // Checks if the key to map is in the dictionary to map
                if ([resourceObjectAttributes objectForKey:key] != nil && [resourceObjectAttributes objectForKey:key] != [NSNull null]) {
                    
                    NSString *property = [userMap objectForKey:key];
                    
                    NSRange formatRange = [property rangeOfString:@":"];
                    
                    @try {
                        if (formatRange.location != NSNotFound) {
                            NSString *formatFunction = [property substringToIndex:formatRange.location];
                            property = [property substringFromIndex:(formatRange.location+1)];
                            
                            [self setValue:[JSONAPIResourceFormatter performFormatBlock:[dict objectForKey:key] withName:formatFunction] forKey:property ];
                        } else {
                            [self setValue:[resourceObjectAttributes objectForKey:key] forKey:property ];
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"JSONAPIResource Warning - %@", [exception description]);
                    }
                    
                } else {
                    NSLog(@"JSONAPIResource Warning : key %@ not found in json data.", key);
                }
                
            }
        }
    }
    
}

- (void)linkWithIncluded:(JSONAPI*)jsonAPI {
    
    NSDictionary *included = jsonAPI.includedResources;
    
    // Loops through links of resources
    NSDictionary *links = self.links;
    for (NSString *linkKey in links.allKeys) {
        
        // Gets linked objects for the resource
        id linksTo = self.links[linkKey];
        if ([linksTo isKindOfClass:[NSDictionary class]] == YES) {
            
            id linkage = linksTo[@"linkage"];
            if ([linkage isKindOfClass:[NSDictionary class]] == YES) {

                NSString *linkType = linkage[@"type"];
                
                if (linkage[@"id"] != nil) {
                    id linksToId = linkage[@"id"];
                    
                    JSONAPIResource *linkedResource = included[linkType][linksToId];
                    if (linkedResource != nil) {
                        [_resourceLinks setObject:linkedResource forKey:linkKey];
                    }
                }

            } else if ([linkage isKindOfClass:[NSArray class]] == YES) {
                
                NSMutableArray *linkedResources = @[].mutableCopy;
                for (NSDictionary *linkageData in linkage) {
                    NSString *linkType = linkageData[@"type"];
                    
                    if (linkageData[@"id"] != nil) {
                        id linksToId = linkageData[@"id"];
                        
                        JSONAPIResource *linkedResource = included[linkType][linksToId];
                        if (linkedResource != nil) {
                            [linkedResources addObject:linkedResources];
                        }
                    }
                }
                [_resourceLinks setObject:linkedResources forKey:linkKey];
                
            }
        }
    }
    
    // Link links for mapped key to properties
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

//#pragma mark - NSCopying
//
//- (id)copyWithZone:(NSZone *)zone {
//    id copy = [[[self class] alloc] initWithDictionary:[_dictionary copyWithZone:zone]];
//    
//    if (copy) {
//        // Copy NSObject subclasses
//        NSLog(@"__resourceLinks - %@", _resourceLinks);
//        [copy set_resourceLinks:[_resourceLinks copyWithZone:zone]];
//        
//        // Link links for mapped key to properties
//        for (NSString *key in [copy _resourceLinks]) {
//            @try {
//                [copy setValue:[[copy _resourceLinks] objectForKey:key] forKey:key];
//            }
//            @catch (NSException *exception) {
//                NSLog(@"JSONAPIResource Warning - %@", [exception description]);
//            }
//        }
//
//    }
//    
//    return copy;
//}
//
//#pragma mark - NSCoding
//
//- (NSArray *)propertyKeys
//{
//    NSMutableArray *array = [NSMutableArray array];
//    Class class = [self class];
//    while (class != [NSObject class])
//    {
//        unsigned int propertyCount;
//        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
//        for (int i = 0; i < propertyCount; i++)
//        {
//            //get property
//            objc_property_t property = properties[i];
//            const char *propertyName = property_getName(property);
//            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
//            
//            //check if read-only
//            BOOL readonly = NO;
//            const char *attributes = property_getAttributes(property);
//            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
//            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
//            {
//                readonly = YES;
//                
//                //see if there is a backing ivar with a KVC-compliant name
//                NSRange iVarRange = [encoding rangeOfString:@",V"];
//                if (iVarRange.location != NSNotFound)
//                {
//                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
//                    if ([iVarName isEqualToString:key] ||
//                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
//                    {
//                        //setValue:forKey: will still work
//                        readonly = NO;
//                    }
//                }
//            }
//            
//            if (!readonly)
//            {
//                //exclude read-only properties
//                [array addObject:key];
//            }
//        }
//        free(properties);
//        class = [class superclass];
//    }
//    return array;
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    if ((self = [self init]))
//    {
//        for (NSString *key in [self propertyKeys])
//        {
//            id value = [aDecoder decodeObjectForKey:key];
//            [self setValue:value forKey:key];
//        }
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    for (NSString *key in [self propertyKeys])
//    {
//        id value = [self valueForKey:key];
//        [aCoder encodeObject:value forKey:key];
//    }
//}

@end

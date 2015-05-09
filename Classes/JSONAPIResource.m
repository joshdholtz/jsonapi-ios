//
//  JSONAPIResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

#import "JSONAPI.h"
#import "JSONAPIResourceDescriptor.h"
#import "JSONAPIPropertyDescriptor.h"

#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - JSONAPIResource

@interface JSONAPIResource()

/*!
 * Allocate a resource link instance from a deserialized JSON dictionary. The dictionary argument
 * should describe one resource in JSON API format. This must be a JSON API "links" element.
 * It is not a complete JSON API response block.
 *
 * This will return either a JSONAPIResource instance, or an NSArray of JSONAPIResource instances.
 */
+ (id)jsonAPILink:(NSDictionary*)dictionary;

/*!
 * Generate a 'links' element for the data dictionary of the owner resource instance.
 *
 * A 'links' element contains the self link, a 'related' link that can be used to
 * retrieve this instance given the container data, and a 'linkage' element that
 * describes the minimum respresentation of this instance (type and ID).
 */
- (NSDictionary*)linkFrom:(JSONAPIResource*)owner withKey:(NSString*)key;

@end

@implementation JSONAPIResource

#pragma mark -
#pragma mark - Class Methods

+ (NSArray*)jsonAPIResources:(NSArray*)array {
    
    NSMutableArray *mutableArray = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        NSString *type = dict[@"type"] ?: @"";
        JSONAPIResourceDescriptor *resource = [JSONAPIResourceDescriptor forLinkedType:type];
        [mutableArray addObject:[[[resource resourceClass] alloc] initWithDictionary:dict]];
    }
    
    return mutableArray;
}

+ (instancetype)jsonAPIResource:(NSDictionary*)dictionary {
    NSString *type = dictionary[@"type"] ?: @"";
    JSONAPIResourceDescriptor *resource = [JSONAPIResourceDescriptor forLinkedType:type];
    
    return [[[resource resourceClass] alloc] initWithDictionary:dictionary];
}

+ (id)jsonAPILink:(NSDictionary*)dictionary {
    id linkage = dictionary[@"linkage"];
    if ([linkage isKindOfClass:[NSArray class]]) {
        NSMutableArray *linkArray = [[NSMutableArray alloc] initWithCapacity:[linkage count]];
        for (NSDictionary *linkElement in linkage) {
            [linkArray addObject:[JSONAPIResource jsonAPIResource:linkElement]];
        }
        
        return linkArray;
        
    } else {
        return [JSONAPIResource jsonAPIResource:linkage];
    }
}

+ (JSONAPIResourceDescriptor *)descriptor {
    // subclass must override
    return nil;
}

#pragma mark -
#pragma mark - Instance Methods

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [self init];
    if (self) {
        [self setWithDictionary:dict];
    }
    return self;
}

- (void)setWithDictionary:(NSDictionary*)dict {
    JSONAPIResourceDescriptor *descriptor = [[self class] descriptor];
    
    NSDictionary *jsonLinks = [dict objectForKey:@"links"];
    
    self.self_link = [jsonLinks valueForKey:@"self"];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        if (property.resourceType) {
            if (jsonLinks) {
                id value = [jsonLinks objectForKey:[property jsonName]];
                [self setValue:[JSONAPIResource jsonAPILink:value] forKey:key];
            }
            
        } else {
            id value = [dict objectForKey:[property jsonName]];
            if (value) {
                // anything else should be a value property
                NSFormatter *format = [property formatter];
                NSString *error;
                
                if ([value isKindOfClass:[NSArray class]]) {
                    if (format) {
                        NSMutableArray *temp = [value copy];
                        for (int i=0; i < [value length]; ++i) {
                            id xformed;
                            if ([format getObjectValue:&xformed forString:temp[i] errorDescription:&error]) {
                                temp[i] = xformed;
                            }
                        }
                        [self setValue:temp forKey:key];
                    } else {
                        [self setValue:[[NSArray alloc] initWithArray:value] forKey:key];
                    }
                    
                } else {
                    if (format) {
                        id xformed;
                        if ([format getObjectValue:&xformed forString:value errorDescription:&error]) {
                            [self setValue:xformed forKey:key];
                        }
                    } else {
                        [self setValue:value forKey:key];
                    }
                }
            }
        }
    }
}

- (void)linkWithIncluded:(JSONAPI*)jsonAPI {
    
    NSDictionary *included = jsonAPI.includedResources;
    if (nil == included) return;
    
    JSONAPIResourceDescriptor *descriptor = [[self class] descriptor];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        if (property.resourceType) {
            id value = [self valueForKey:key];
            if (value) {
                if ([value isKindOfClass:[NSArray class]]) {
                    for (JSONAPIResource *resource in value) {
                        id include = included[property.resourceType][resource.ID];
                        if (include) {
                            [resource setWithDictionary:include];
                        }
                    }
                } else {
                    JSONAPIResource *resource = value;
                    id include = included[property.resourceType][resource.ID];
                    if (include) {
                        [resource setWithDictionary:include];
                    }
                }
            }
        }
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    // linkage is only allocated if there are 1 or more links
    NSMutableDictionary *linkage = nil;
    
    JSONAPIResourceDescriptor *descriptor = [[self class] descriptor];
    
    [dictionary setValue:[descriptor type] forKey: @"type"];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        
        id value = [self valueForKey:key];
        if (value) {
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *selfArray = value;
                if (selfArray.count > 0) {
                    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:selfArray.count];
                    
                    if ([property resourceType]) {
                        if (linkage == nil) {
                            linkage = [[NSMutableDictionary alloc] init];
                        }
                        
                        for (id valueElement in selfArray) {
                            JSONAPIResource *resource = valueElement;
                            [valueArray addObject:[resource linkFrom:self withKey:[property jsonName]]];
                        }
                        
                        [linkage setValue:valueArray forKey:[property jsonName]];
                        
                    } else {
                        NSFormatter *format = [property formatter];
                        
                        for (id valueElement in selfArray) {
                            if (format) {
                                [valueArray addObject:[format stringForObjectValue:valueElement]];
                            } else {
                                [valueArray addObject:valueElement];
                            }
                        }
                        
                        [dictionary setValue:valueArray forKey:[property jsonName]];
                    }
                }
            } else {
                if ([property resourceType]) {
                    if (linkage == nil) {
                        linkage = [[NSMutableDictionary alloc] init];
                    }
                    
                    JSONAPIResource *resource = value;
                    [linkage setValue:[resource linkFrom:self withKey:[property jsonName]] forKey:[property jsonName]];
                } else {
                    NSFormatter *format = [property formatter];
                    if (format) {
                        [dictionary setValue:[format stringForObjectValue:value] forKey:[property jsonName]];
                    } else {
                        [dictionary setValue:value forKey:[property jsonName]];
                    }
                }
            }
        }
    }
    
    if (linkage) {
        if (self.self_link) {
            [linkage setValue:self.self_link forKey:@"self"];
        }
        [dictionary setValue:linkage forKey:@"links"];
    }
    
    return dictionary;
}

- (NSArray*)relatedResources {
    NSMutableArray *included = [[NSMutableArray alloc] init];
    
    JSONAPIResourceDescriptor *descriptor = [[self class] descriptor];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        
        if (property.resourceType) {
            id value = [self valueForKey:key];
            if ([value isKindOfClass:[NSArray class]]) {
                for (JSONAPIResource *resource in value) {
                    [included addObject:[resource dictionary]];
                }
            } else {
                JSONAPIResource *resource = value;
                [included addObject:[resource dictionary]];
            }
        }
    }
    
    return included;
}

- (NSDictionary*)linkFrom:(JSONAPIResource*)owner withKey:(NSString*)key {
    JSONAPIResourceDescriptor *descriptor = [[self class] descriptor];
    NSMutableDictionary *reference = [[NSMutableDictionary alloc] init];
    
    if (self.self_link) {
        [reference setValue:self.self_link forKey:@"self"];
    }
    
    if (owner.self_link) {
        NSMutableString *related = [[NSMutableString alloc] initWithString:owner.self_link];
        [related appendString:@"/"];
        [related appendString:key];
        [reference setValue:related forKey:@"related"];
    }
    
    if (self.ID) {
        [reference setValue:@{
                              @"type" : descriptor.type,
                              @"id"   : self.ID
                              } forKey:@"linkage"];
    }
    
    return reference;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] initWithDictionary:[self.dictionary copyWithZone:zone]];
    return copy;
}

#pragma mark - NSCoding

- (NSArray *)propertyKeys
{
    NSMutableArray *array = [NSMutableArray array];
    Class class = [self class];
    while (class != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //check if read-only
            BOOL readonly = NO;
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
            {
                readonly = YES;
                
                //see if there is a backing ivar with a KVC-compliant name
                NSRange iVarRange = [encoding rangeOfString:@",V"];
                if (iVarRange.location != NSNotFound)
                {
                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
                    if ([iVarName isEqualToString:key] ||
                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //setValue:forKey: will still work
                        readonly = NO;
                    }
                }
            }
            
            if (!readonly)
            {
                //exclude read-only properties
                [array addObject:key];
            }
        }
        free(properties);
        class = [class superclass];
    }
    return array;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [self init]))
    {
        for (NSString *key in [self propertyKeys])
        {
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self propertyKeys])
    {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

@end

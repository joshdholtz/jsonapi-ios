//
//  JSONAPIResourceParser.m
//  JSONAPI
//

#import "JSONAPIResourceParser.h"

#import "JSONAPI.h"
#import "JSONAPIResourceDescriptor.h"
#import "JSONAPIPropertyDescriptor.h"

#pragma mark - JSONAPIResourceParser

@interface JSONAPIResourceParser()

/**
 * Initialize the instance properties from the JSON dictionary.
 *
 * @param resource model object
 * @param dictionary JSON-API data dictionary
 */
+ (void)set:(NSObject <JSONAPIResource> *)resource withDictionary:dictionary;

/**
 * Allocate a resource link instance from a deserialized JSON dictionary. The dictionary argument
 * should describe one resource in JSON API format. This must be a JSON API "links" element.
 * It is not a complete JSON API response block.
 *
 * This will return either a <JSONAPIResource> instance, or an NSArray of <JSONAPIResource> instances.
 *
 * @param dictionary deserialized JSON data object
 *
 * @return initialized resource instance.
 */
+ (id)jsonAPILink:(NSDictionary*)dictionary;


/**
 * Generate a 'links' element for the data dictionary of the owner resource instance.
 *
 * A 'links' element contains the self link, a 'related' link that can be used to
 * retrieve this instance given the container data, and a 'linkage' element that
 * describes the minimum respresentation of this instance (type and ID).
 *
 * @param resource model object
 * @param owner the resource instance that contains the model object
 * @param key label used in JSON for **owner** property linked to the model object
 *
 * @return newly allocated JSON dictionary for linkage
 */
+ (NSDictionary*)link:(NSObject <JSONAPIResource>*)resource from:(NSObject <JSONAPIResource>*)owner withKey:(NSString*)key;

@end

@implementation JSONAPIResourceParser

#pragma mark -
#pragma mark - Class Methods

+ (NSArray*)parseResources:(NSArray*)array {
    
    NSMutableArray *mutableArray = @[].mutableCopy;
    for (NSDictionary *dictionary in array) {
        [mutableArray addObject:[self parseResource:dictionary]];
    }
    
    return mutableArray;
}

+ (id <JSONAPIResource>)parseResource:(NSDictionary*)dictionary {
    NSString *type = dictionary[@"type"] ?: @"";
    JSONAPIResourceDescriptor *descriptor = [JSONAPIResourceDescriptor forLinkedType:type];
    
    NSObject <JSONAPIResource> *resource = [[descriptor resourceClass] alloc];
    [self set:resource withDictionary:dictionary];
    
    return resource;
}


+ (void)set:(NSObject <JSONAPIResource> *)resource withDictionary:dictionary {
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    NSDictionary *jsonLinks = [dictionary objectForKey:@"links"];
    
    resource.selfLink = [jsonLinks valueForKey:@"self"];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        if (property.resourceType) {
            if (jsonLinks) {
                id value = [jsonLinks objectForKey:[property jsonName]];
                [resource setValue:[JSONAPIResourceParser jsonAPILink:value] forKey:key];
            }
            
        } else {
            id value = [dictionary objectForKey:[property jsonName]];
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
                        [resource setValue:temp forKey:key];
                    } else {
                        [resource setValue:[[NSArray alloc] initWithArray:value] forKey:key];
                    }
                    
                } else {
                    if (format) {
                        id xformed;
                        if ([format getObjectValue:&xformed forString:value errorDescription:&error]) {
                            [resource setValue:xformed forKey:key];
                        }
                    } else {
                        [resource setValue:value forKey:key];
                    }
                }
            }
        }
    }
}

+ (id)jsonAPILink:(NSDictionary*)dictionary {
    id linkage = dictionary[@"linkage"];
    if ([linkage isKindOfClass:[NSArray class]]) {
        NSMutableArray *linkArray = [[NSMutableArray alloc] initWithCapacity:[linkage count]];
        for (NSDictionary *linkElement in linkage) {
            [linkArray addObject:[JSONAPIResourceParser parseResource:linkElement]];
        }
        
        return linkArray;
        
    } else {
        return [JSONAPIResourceParser parseResource:linkage];
    }
}


+ (void)link:(NSObject <JSONAPIResource>*)resource withIncluded:(JSONAPI*)jsonAPI {
    
    NSDictionary *included = jsonAPI.includedResources;
    if (nil == included) return;
    
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        if (property.resourceType) {
            id value = [resource valueForKey:key];
            if (value) {
                if ([value isKindOfClass:[NSArray class]]) {
                    for (NSObject <JSONAPIResource> *element in value) {
                        id include = included[property.resourceType][element.ID];
                        if (include) {
                            [self set:element withDictionary:include];
                        }
                    }
                } else {
                    NSObject <JSONAPIResource> *attribute = value;
                    id include = included[property.resourceType][attribute.ID];
                    if (include) {
                        [self set:attribute withDictionary:include];
                    }
                }
            }
        }
    }
}

+ (NSDictionary*)dictionaryFor:(NSObject <JSONAPIResource>*)resource {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    // linkage is only allocated if there are 1 or more links
    NSMutableDictionary *linkage = nil;
    
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    
    [dictionary setValue:[descriptor type] forKey: @"type"];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        
        id value = [resource valueForKey:key];
        if (value) {
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray *valueArray = value;
                if (valueArray.count > 0) {
                    NSMutableArray *dictionaryArray = [[NSMutableArray alloc] initWithCapacity:valueArray.count];
                    
                    if ([property resourceType]) {
                        if (linkage == nil) {
                            linkage = [[NSMutableDictionary alloc] init];
                        }
                        
                        for (id valueElement in valueArray) {
                            [dictionaryArray addObject:[self link:valueElement from:resource withKey:[property jsonName]]];
                        }
                        
                        [linkage setValue:dictionaryArray forKey:[property jsonName]];
                        
                    } else {
                        NSFormatter *format = [property formatter];
                        
                        for (id valueElement in valueArray) {
                            if (format) {
                                [dictionaryArray addObject:[format stringForObjectValue:valueElement]];
                            } else {
                                [dictionaryArray addObject:valueElement];
                            }
                        }
                        
                        [dictionary setValue:dictionaryArray forKey:[property jsonName]];
                    }
                }
            } else {
                if ([property resourceType]) {
                    if (linkage == nil) {
                        linkage = [[NSMutableDictionary alloc] init];
                    }
                    
                    NSObject <JSONAPIResource> *attribute = value;
                    [linkage setValue:[self link:attribute from:resource withKey:[property jsonName]] forKey:[property jsonName]];
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
        if (resource.selfLink) {
            [linkage setValue:resource.selfLink forKey:@"self"];
        }
        [dictionary setValue:linkage forKey:@"links"];
    }
    
    return dictionary;
}

+ (NSArray*)relatedResourcesFor:(NSObject <JSONAPIResource>*)resource {
    NSMutableArray *related = [[NSMutableArray alloc] init];
    
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        
        if (property.resourceType) {
            id value = [self valueForKey:key];
            if ([value isKindOfClass:[NSArray class]]) {
                for (NSObject <JSONAPIResource> *element in value) {
                    [related addObject:[JSONAPIResourceParser dictionaryFor:element]];
                }
            } else {
                NSObject <JSONAPIResource> *attribute = value;
                [related addObject:[JSONAPIResourceParser dictionaryFor:attribute]];
            }
        }
    }
    
    return related;
}

+ (NSDictionary*)link:(NSObject <JSONAPIResource>*)resource from:(NSObject <JSONAPIResource>*)owner withKey:(NSString*)key {
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    NSMutableDictionary *reference = [[NSMutableDictionary alloc] init];
    
    if (owner.selfLink) {
        NSMutableString *link_to_self = [owner.selfLink mutableCopy];
        [link_to_self appendString:@"/links/"];
        [link_to_self appendString:key];
        [reference setValue:link_to_self forKey:@"self"];
        
        NSMutableString *related = [owner.selfLink mutableCopy];
        [related appendString:@"/"];
        [related appendString:key];
        [reference setValue:related forKey:@"related"];
    }
    
    if (resource.ID) {
        [reference setValue:@{
                              @"type" : descriptor.type,
                              @"id"   : resource.ID
                              } forKey:@"linkage"];
    }
    
    return reference;
}

@end

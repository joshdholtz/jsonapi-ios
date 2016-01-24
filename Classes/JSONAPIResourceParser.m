//
//  JSONAPIResourceParser.m
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import "JSONAPIResourceParser.h"

#import "JSONAPI.h"
#import "JSONAPIResourceDescriptor.h"
#import "JSONAPIPropertyDescriptor.h"

#pragma mark - JSONAPIResourceParser

@interface JSONAPIResourceParser()

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


+ (id <JSONAPIResource>)parseResource:(NSDictionary*)dictionary {
    NSString *type = dictionary[@"type"] ?: @"";
    JSONAPIResourceDescriptor *descriptor = [JSONAPIResourceDescriptor forLinkedType:type];
    
    NSObject <JSONAPIResource> *resource = [[[descriptor resourceClass] alloc] init];
    [self set:resource withDictionary:dictionary];
    
    return resource;
}

+ (NSArray*)parseResources:(NSArray*)array {
    
    NSMutableArray *mutableArray = @[].mutableCopy;
    for (NSDictionary *dictionary in array) {
        NSObject <JSONAPIResource> *resource = [self parseResource:dictionary];
        if(resource) {
            [mutableArray addObject:resource];
        }
    }
    
    return mutableArray;
}

+ (NSDictionary*)dictionaryFor:(NSObject <JSONAPIResource>*)resource {
    NSFormatter *format;
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    // linkage is only allocated if there are 1 or more links
    NSMutableDictionary *linkage = nil;
    
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    
    [dictionary setValue:[descriptor type] forKey: @"type"];
    
    id ID = [resource valueForKey:[descriptor idProperty]];
    if (ID) {
        // ID optional only for create (POST request)
        format = [descriptor idFormatter];
        if (format) {
            [dictionary setValue:[format stringForObjectValue:ID] forKey:@"id"];
        } else {
            [dictionary setValue:ID forKey:@"id"];
        }
    }

    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
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
                    
                    if ([property resourceType] || [((NSArray *)value).firstObject conformsToProtocol:@protocol(JSONAPIResource)]) {
                        if (linkage == nil) {
                            linkage = [[NSMutableDictionary alloc] init];
                        }
                        
                        for (id valueElement in valueArray) {
                            [dictionaryArray addObject:[self link:valueElement from:resource withKey:[property jsonName]]];
                        }
                        
                        NSDictionary *dataDictionary = @{@"data" : dictionaryArray};
                        [linkage setValue:dataDictionary forKey:[property jsonName]];
                    } else {
                        NSFormatter *format = [property formatter];
                        
                        for (id valueElement in valueArray) {
                            if (format) {
                                [dictionaryArray addObject:[format stringForObjectValue:valueElement]];
                            } else {
                                [dictionaryArray addObject:valueElement];
                            }
                        }
                        
                        [attributes setValue:dictionaryArray forKey:[property jsonName]];
                    }
                }
            } else {
                if ([property resourceType] || [value conformsToProtocol:@protocol(JSONAPIResource)]) {
                    if (linkage == nil) {
                        linkage = [[NSMutableDictionary alloc] init];
                    }
                    
                    NSObject <JSONAPIResource> *attribute = value;
                    [linkage setValue:[self link:attribute from:resource withKey:[property jsonName]] forKey:[property jsonName]];
                } else {
                    format = [property formatter];
                    if (format) {
                        [attributes setValue:[format stringForObjectValue:value] forKey:[property jsonName]];
                    } else {
                        [attributes setValue:value forKey:[property jsonName]];
                    }
                }
            }
        }
    }
    
    if (attributes.count > 0) {
        [dictionary setValue:attributes forKey:@"attributes"];
    }
    
    if (linkage) {
        [dictionary setValue:linkage forKey:@"relationships"];
    }
	
	// TODO: Need to also add in all other links
	if (resource.selfLink) {
		dictionary[@"links"] = @{ @"self": resource.selfLink };
	}
	
    return dictionary;
}

+ (void)set:(NSObject <JSONAPIResource> *)resource withDictionary:dictionary {
    NSString *error;

    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    
    NSDictionary *relationships = [dictionary objectForKey:@"relationships"];
    NSDictionary *attributes = [dictionary objectForKey:@"attributes"];
    NSDictionary *links = [dictionary objectForKey:@"links"];
	
    id ID = [dictionary objectForKey:@"id"];
    NSFormatter *format = [descriptor idFormatter];
    if (format) {
        id xformed;
        if ([format getObjectValue:&xformed forString:ID errorDescription:&error]) {
            [resource setValue:xformed forKey:[descriptor idProperty]];
        }
    } else {
        [resource setValue:ID forKey:[descriptor idProperty]];
    }
    
    if (descriptor.selfLinkProperty) {
        NSString *selfLink = links[@"self"];
        [resource setValue:selfLink forKey:descriptor.selfLinkProperty];
    }

    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        
        if (property.resourceType) {
            if (relationships) {
                id value = [relationships objectForKey:[property jsonName]];
                if (value[@"data"] != [NSNull null]) {
                    [resource setValue:[JSONAPIResourceParser jsonAPILink:value] forKey:key];
                }
            }
            
        } else if (relationships[key]) {
            if (relationships) {
                id value = relationships[key];
                if (value[@"data"] != [NSNull null]) {
                    [resource setValue:[JSONAPIResourceParser jsonAPILink:value] forKey:key];
                }
            }
        } else {
            id value = [attributes objectForKey:[property jsonName]];
            if ((id)[NSNull null] == value) {
                value = [dictionary objectForKey:[property jsonName]];
            }
            
            if (value) {
                // anything else should be a value property
                format = [property formatter];
                
                if ([value isKindOfClass:[NSArray class]]) {
                    if (format) {
                        NSMutableArray *temp = [value mutableCopy];
                        for (int i = 0; i < [value count]; ++i) {
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
    id linkage = dictionary[@"data"];
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
        JSONAPIPropertyDescriptor *propertyDescriptor = [properties objectForKey:key];
        id value = [resource valueForKey:key];
        
        Class valueClass = nil;
        if (propertyDescriptor.resourceType) {
            valueClass = propertyDescriptor.resourceType;
        } else if ([value conformsToProtocol:@protocol(JSONAPIResource)] || [value isKindOfClass:[NSArray class]]) {
            valueClass = [value class];
        }
        
        // ordinary attribute
        if (valueClass == nil) {
            continue;
        // has many
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *matched = [value mutableCopy];
            [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj conformsToProtocol:@protocol(JSONAPIResource)]) {
                    NSObject <JSONAPIResource> *res = obj;
                    id includedValue = included[[[res.class descriptor] type]];
                    if (includedValue) {
                        id v = includedValue[res.ID];
                        if (v != nil) {
                            matched[idx] = v;
                        }
                    }
                }
            }];

            [resource setValue:matched forKey:key];
        // has one
        } else if (value != nil) {
            if ([value conformsToProtocol:@protocol(JSONAPIResource)]) {
                id <JSONAPIResource> res = value;
                id includedValue = included[[[res.class descriptor] type]];
                if (includedValue) {
                    id v = included[[[res.class descriptor] type]][res.ID];
                    if (v != nil) {
                        [resource setValue:v forKey:key];
                    }
                }
            }
        }
    }
}

+ (NSArray*)relatedResourcesFor:(NSObject <JSONAPIResource>*)resource {
    NSMutableArray *related = [[NSMutableArray alloc] init];
    
    JSONAPIResourceDescriptor *descriptor = [[resource class] descriptor];
    
    // Loops through all keys to map to properties
    NSDictionary *properties = [descriptor properties];
    for (NSString *key in properties) {
        JSONAPIPropertyDescriptor *property = [properties objectForKey:key];
        if (property.resourceType) {
            id value = [resource valueForKey:key];
            if ([value isKindOfClass:[NSArray class]]) {
                [related addObjectsFromArray:value];
            } else {
                [related addObject:value];
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
        NSDictionary *referenceObject = @{
                                          @"type" : descriptor.type,
                                          @"id"   : resource.ID
                                          };
        if ([[owner valueForKey:key] isKindOfClass:[NSArray class]]) {
            reference = referenceObject.mutableCopy;
        } else {
            [reference setValue:referenceObject forKey:@"data"];
        }
    }
    
    return reference;
}

@end

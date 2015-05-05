//
//  JSONAPITopLevel.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPI.h"

#import "JSONAPIErrorResource.h"
#import "JSONAPIResourceDescriptor.h"


static NSString *gMEDIA_TYPE = @"application/vnd.api+json";

@interface JSONAPI()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation JSONAPI

#pragma mark - Class

+ (NSString*)MEDIA_TYPE {
    return gMEDIA_TYPE;
}

+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary {
    return [[JSONAPI alloc] initWithDictionary:dictionary];
}

+ (instancetype)jsonAPIWithString:(NSString *)string {
    return [[JSONAPI alloc] initWithString:string];
}

+ (instancetype)jsonAPIWithResource:(JSONAPIResource *)resource {
    return [[JSONAPI alloc] initWithResource:resource];
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

-(instancetype)initWithResource:(JSONAPIResource*)resource {
    self = [super init];
    if (self) {
        [self inflateWithResource:resource];
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

- (id)includedResource:(id)ID withType:(NSString *)type {
    if (ID == nil) return nil;
    if (type == nil) return nil;
    return _includedResources[type][ID];
}

- (BOOL)hasErrors {
    return _errors.count > 0;
}

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
    
    // Parses included resources
    NSArray *included = _dictionary[@"included"];
    NSMutableDictionary *includedResources = @{}.mutableCopy;
    for (NSDictionary *data in included) {
        
        JSONAPIResource *resource = [self inflateResourceData:data];
        if (resource) {
            JSONAPIResourceDescriptor *desc = [JSONAPIResourceDescriptor forLinkedType:data[@"type"]];
            
            NSMutableDictionary *typeDict = includedResources[desc.type] ?: @{}.mutableCopy;
            typeDict[resource.ID] = resource;
            
            includedResources[desc.type] = typeDict;
        }
    }
    _includedResources = includedResources;
    
    // Link included with included
    // TODO: Need to look into / stop circular references
    for (NSDictionary *typeIncluded in _includedResources.allValues) {
        for (JSONAPIResource *resource in typeIncluded.allValues) {
            [resource linkWithIncluded:self];
        }
    }
    
    // Link data with included
    for (JSONAPIResource *resource in _resources) {
        [resource linkWithIncluded:self];
    }
    
    // Parse errors
    NSMutableArray *errors = @[].mutableCopy;
    if (errors) {
        NSLog(@"ERRORS - %@", _dictionary[@"errors"]);
        for (NSDictionary *data in _dictionary[@"errors"]) {
            
            JSONAPIErrorResource *resource = [[JSONAPIErrorResource alloc] initWithDictionary:data];
            NSLog(@"Error resource - %@", resource);
            if (resource) [errors addObject:resource];
        }
        _errors = errors;
    }
}

- (id)inflateResourceData:(NSDictionary*)data {
    return [JSONAPIResource jsonAPIResource:data];
}

- (void)inflateWithResource:(JSONAPIResource*)resource
{
    NSMutableArray *resourceArray = [[NSMutableArray alloc] init];
    [resourceArray addObject:resource];
    _resources = resourceArray;
    
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
    
    _data = [resource dictionary];
    newDictionary[@"data"] = _data;
    
    NSArray *included = [resource relatedResources];
    if (included.count) {
        newDictionary[@"included"] = included;
        
        NSMutableDictionary *includedResources = @{}.mutableCopy;
        for (JSONAPIResource *resource in included) {
            
            JSONAPIResourceDescriptor *desc = [[resource class] descriptor];
            
            NSMutableDictionary *typeDict = includedResources[desc.type] ?: @{}.mutableCopy;
            typeDict[resource.ID] = resource;
            
            includedResources[desc.type] = typeDict;
        }
        _includedResources = includedResources;
    }
    
    _dictionary = newDictionary;
}

@end

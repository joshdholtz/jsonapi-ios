//
//  JSONAPITopLevel.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPI.h"

#import "JSONAPIErrorResource.h"

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

- (id)includedResource:(id)ID withType:(NSString *)type {
    if (ID == nil) return nil;
    if (type == nil) return nil;
    return _includedResources[type][ID];
}

- (BOOL)hasErrors {
    return _errors.count > 0;
}

- (NSMutableArray *)arrayFromDictionary:(NSDictionary *)dictionary withKey:(NSString *)key
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    if([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]]) {
        [array addObject:[dictionary objectForKey:key]];
    }
    else {
        array = [dictionary objectForKey:key];
    }
    
    return array;
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

            NSMutableDictionary *typeDict = includedResources[resource.type] ?: @{}.mutableCopy;
            typeDict[resource.ID] = resource;
            
            includedResources[resource.type] = typeDict;
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
    NSLog(@"ERROS - %@", _dictionary[@"errors"]);
    for (NSDictionary *data in _dictionary[@"errors"]) {
        
        JSONAPIErrorResource *resource = [[JSONAPIErrorResource alloc] initWithDictionary:data];
        NSLog(@"Error resource - %@", resource);
        if (resource) [errors addObject:resource];
    }
    _errors = errors;
}

- (id)inflateResourceData:(NSDictionary*)data {
    return [JSONAPIResource jsonAPIResource:data];
}

@end

//
//  JSONAPITopLevel.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPI.h"

#import "JSONAPIErrorResource.h"

@interface JSONAPI(){

    NSDictionary *_dictionary;
}

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

- (BOOL)hasErrors {
    return _errors.count > 0;
}

#pragma mark - Private

- (void)inflateWithDictionary:(NSDictionary*)dictionary {
    
    // Sets internal dictionary
    _dictionary = dictionary;
    
    // Sets meta
    _meta = dictionary[@"meta"];
    if (![_meta isKindOfClass:[NSDictionary class]]) {
        _meta = nil;
    }
    
    // Parse resources
    id rawData = _dictionary[@"data"];
    
    NSMutableArray *resources = [NSMutableArray new];
    if ([rawData isKindOfClass:[NSArray class]]) {
        
        NSArray *rawResourcesArray = (NSArray*) rawData;
        for (NSDictionary *rawResource in rawResourcesArray) {
            id resource = [self inflateResourceData:rawResource];
            if (resource) [resources addObject:resource];
        }
        
        _data = resources;
        
    } else if ([rawData isKindOfClass:[NSDictionary class]]) {
        id resource = [self inflateResourceData: rawData];
        if (resource) _data = resource;
    }
    
    // Parses included resources
    NSArray *rawIncludedArray = _dictionary[@"included"];
    NSMutableArray *includedResources = [NSMutableArray new];
    for (NSDictionary *data in rawIncludedArray) {
        JSONAPIResource *resource = [self inflateResourceData:data];
        if (resource) [includedResources addObject: resource];
    }
    _included = includedResources;
    
    if([_data isKindOfClass:[NSArray class]]){
        for (JSONAPIResource *thisResource in _data) {
            thisResource.includedResources = [self includedResourcesForJSONAPIResource: thisResource];
        }
    }
    else{
        ((JSONAPIResource *)_data).includedResources = [self includedResourcesForJSONAPIResource: (JSONAPIResource *)_data];
    }
    
    // Parse errors
    NSMutableArray *returnedErrors = [NSMutableArray new];
    for (NSDictionary *rawError in _dictionary[@"errors"]) {
        
        JSONAPIErrorResource *resource = [[JSONAPIErrorResource alloc] initWithDictionary:rawError];
        if (resource) [returnedErrors addObject:resource];
    }
    _errors = returnedErrors;
}

- (id)inflateResourceData:(NSDictionary*)data {
    return [JSONAPIResource jsonAPIResource:data];
}

- (NSArray *) includedResourcesForJSONAPIResource:(JSONAPIResource *)resource{
    
    NSMutableArray *includedResources = [NSMutableArray new];
    
    for(NSDictionary *relationship in [resource.relationships allValues]){
        NSDictionary *relationshipData = (relationship[@"data"] && (relationship[@"data"] != [NSNull null])) ? relationship[@"data"] : nil;
        if(relationshipData){
            
            if([relationshipData isKindOfClass:[NSArray class]]){
                for (NSDictionary *thisResourceIdentifier in relationshipData) {
                    NSString *relationshipType = thisResourceIdentifier[@"type"];
                    NSString *relationshipId = thisResourceIdentifier[@"id"];
                    
                    for(JSONAPIResource *thisResource in _included){
                        if([thisResource.ID isEqualToString: relationshipId] && [thisResource.type isEqualToString: relationshipType])
                            [includedResources addObject: thisResource];
                    }

                }
            }
            else{
                NSString *relationshipType = relationshipData[@"type"];
                NSString *relationshipId = relationshipData[@"id"];
                
                for(JSONAPIResource *thisResource in _included){
                    if([thisResource.ID isEqualToString: relationshipId] && [thisResource.type isEqualToString: relationshipType])
                        [includedResources addObject: thisResource];
                }
            }
        }
    }
    
    return includedResources;

}

@end

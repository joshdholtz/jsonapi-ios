//
//  JSONAPITopLevel.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPI.h"

#import "JSONAPIErrorResource.h"
#import "JSONAPIResourceParser.h"
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

+ (instancetype)jsonAPIWithResource:(NSObject <JSONAPIResource> *)resource {
    return [[JSONAPI alloc] initWithResource:resource];
}

#pragma mark - Instance

- (NSDictionary*)meta {
    return self.dictionary[@"meta"];
}

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

-(instancetype)initWithResource:(NSObject <JSONAPIResource> *)resource {
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
    
    // Parse resources
    id data = dictionary[@"data"];
    if ([data isKindOfClass:[NSArray class]] == YES) {
        _resources = [JSONAPIResourceParser parseResources:data];
        
    } else if ([data isKindOfClass:[NSDictionary class]] == YES) {
        id resource = [JSONAPIResourceParser parseResource:data];
        _resources = [[NSArray alloc] initWithObjects:resource, nil];
    }
    
    // Parses included resources
    id included = dictionary[@"included"];
    NSMutableDictionary *includedResources = [[NSMutableDictionary alloc] init];
    if ([included isKindOfClass:[NSArray class]] == YES) {
        for (NSDictionary *data in included) {
            
            NSObject <JSONAPIResource> *resource = [JSONAPIResourceParser parseResource:data];
            if (resource) {
                JSONAPIResourceDescriptor *desc = [JSONAPIResourceDescriptor forLinkedType:data[@"type"]];
                
                NSMutableDictionary *typeDict = includedResources[desc.type] ?: @{}.mutableCopy;
                typeDict[resource.ID] = resource;
                
                includedResources[desc.type] = typeDict;
            }
        }
    } else if ([included isKindOfClass:[NSDictionary class]] == YES) {
        NSObject <JSONAPIResource> *resource = [JSONAPIResourceParser parseResource:included];
        if (resource) {
            JSONAPIResourceDescriptor *desc = [JSONAPIResourceDescriptor forLinkedType:data[@"type"]];
            
            NSMutableDictionary *typeDict = includedResources[desc.type] ?: @{}.mutableCopy;
            typeDict[resource.ID] = resource;
            
            includedResources[desc.type] = typeDict;
        }
    }
    _includedResources = includedResources;
    
    // Link included with included
    for (NSDictionary *typeIncluded in _includedResources.allValues) {
        for (NSObject <JSONAPIResource> *resource in typeIncluded.allValues) {
            [JSONAPIResourceParser link:resource withIncluded:self];
        }
    }
    
    // Link data with included
    for (NSObject <JSONAPIResource> *resource in _resources) {
        [JSONAPIResourceParser link:resource withIncluded:self];
    }
    
    // Parse errors
    if (dictionary[@"errors"]) {
        NSMutableArray *errors = [[NSMutableArray alloc] init];
        // NSLog(@"ERRORS - %@", dictionary[@"errors"]);
        for (NSDictionary *data in dictionary[@"errors"]) {
            
            JSONAPIErrorResource *resource = [[JSONAPIErrorResource alloc] initWithDictionary: data];
            // NSLog(@"Error resource - %@", resource);
            if (resource) [errors addObject:resource];
        }
        _errors = errors;
    }
}

- (void)inflateWithResource:(NSObject <JSONAPIResource> *)resource
{
    _resources = @[resource];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"data"] = [JSONAPIResourceParser dictionaryFor:resource];
    
    NSArray *relatedResources = [JSONAPIResourceParser relatedResourcesFor:resource];
    if (relatedResources.count) {
        _includedResources = [self mapIncludedResources:relatedResources forResource:resource];
        dictionary[@"included"] = [self parseRelatedResources:relatedResources];
    }
    _dictionary = dictionary;
}

- (NSDictionary *)mapIncludedResources:(NSArray *)relatedResources forResource:(NSObject <JSONAPIResource> *)resource
{
    NSMutableDictionary *includedResources = [NSMutableDictionary new];
    for (NSObject <JSONAPIResource> *linked in relatedResources) {
        JSONAPIResourceDescriptor *desc = [[linked class] descriptor];
        NSMutableDictionary *typeDict = includedResources[desc.type] ?: @{}.mutableCopy;
        typeDict[linked.ID] = resource;
        includedResources[desc.type] = typeDict;
    }
    return includedResources;
}

- (NSArray *)parseRelatedResources:(NSArray *)relatedResources
{
    NSMutableArray *parsedResources = [NSMutableArray new];
    for (NSObject <JSONAPIResource> *linked in relatedResources) {
        [parsedResources addObject:[JSONAPIResourceParser dictionaryFor:linked]];
    }
    return parsedResources;
}

@end

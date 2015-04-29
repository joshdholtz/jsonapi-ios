//
//  JSONAPIResourceDescriptor.m
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong on 4/19/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceDescriptor.h"
#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResource.h"


static NSMutableDictionary *linkedTypeToResource = nil;

@implementation JSONAPIResourceDescriptor

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        linkedTypeToResource = [[NSMutableDictionary alloc] init];
    });
}

+ (void)addResource:(Class)resourceClass {
    JSONAPIResourceDescriptor *descriptor = [resourceClass descriptor];
    NSString *type = descriptor.type;
    [linkedTypeToResource setObject:descriptor forKey:type];
}

+ (instancetype)forLinkedType:(NSString *)linkedType {
    return [linkedTypeToResource objectForKey:linkedType];
}

- (instancetype)initWithClass:(Class)resource forLinkedType:(NSString*)linkedType {
    self = [super init];
    
    if (self) {
        _type = linkedType;
        _resourceClass = resource;
        _properties = [[NSMutableDictionary alloc] init];

        [self addProperty:@"ID" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"id"]];
    }
    
    return self;
}

- (void)addProperty:(NSString*)name {
    [self addProperty:name withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:name]];
}

- (void)addProperty:(NSString*)name withDescription:(JSONAPIPropertyDescriptor*)description {
    [[self properties] setValue:description forKey:name];
}

// note: hasOne and hasMany are identical for now, but seems reasonable to keep both

- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name {
    [self addProperty:name
      withDescription:[[JSONAPIPropertyDescriptor alloc]
                       initWithJsonName:name
                       withResource:jsonApiResource]];
}

- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name {
    [self addProperty:name
      withDescription:[[JSONAPIPropertyDescriptor alloc]
                       initWithJsonName:name
                       withResource:jsonApiResource]];
}

@end

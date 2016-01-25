//
//  JSONAPIResourceDescriptor.m
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import "JSONAPIResourceDescriptor.h"
#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResource.h"


static NSMutableDictionary *linkedTypeToResource = nil;

@implementation JSONAPIResourceDescriptor

/**
 *  Create the 'class' table for all resources.
 */
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        linkedTypeToResource = [[NSMutableDictionary alloc] init];
    });
}

+ (void)addResource:(Class)resourceClass {
    JSONAPIResourceDescriptor *descriptor = [resourceClass descriptor];
    NSAssert(descriptor.type, @"A JSONAPIResourceDescriptor must have a type attribute.");
    NSAssert(descriptor.idProperty, @"A JSONAPIResourceDescriptor must have an id attribute.");
    
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
		
        [self setIdProperty:@"ID"];
        [self setSelfLinkProperty:@"selfLink"];
    }
    
    return self;
}

- (void)addProperty:(NSString*)name {
    [self addProperty:name withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:name]];
}

- (void)addProperty:(NSString*)name withJsonName:(NSString *)json
{
    [self addProperty:name withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:json]];
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

- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json {
    [self addProperty:name
      withDescription:[[JSONAPIPropertyDescriptor alloc]
                       initWithJsonName:json
                       withResource:jsonApiResource]];
}

- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name {
    [self addProperty:name
      withDescription:[[JSONAPIPropertyDescriptor alloc]
                       initWithJsonName:name
                       withResource:jsonApiResource]];
}

- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json {
    [self addProperty:name
      withDescription:[[JSONAPIPropertyDescriptor alloc]
                       initWithJsonName:json
                       withResource:jsonApiResource]];
}

@end

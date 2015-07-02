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
    
    NSDictionary *resourceObjectAttributes = (dict[@"attributes"] && (dict[@"attributes"] != [NSNull null])) ? dict[@"attributes"] : nil;
    if(resourceObjectAttributes){
        self.attributes = resourceObjectAttributes;
    }
    else
        self.attributes = @{};
    
    NSDictionary *resourceObjectRelationships = (dict[@"relationships"] && (dict[@"relationships"] != [NSNull null])) ? dict[@"relationships"] : nil;
    if(resourceObjectRelationships){
        self.relationships = resourceObjectRelationships;
    }
    else
        resourceObjectRelationships = @{};
    
    NSDictionary *userMap = [self mapKeysToProperties];
    if([userMap count]>0){
        
        for (NSString *key in [userMap allKeys]) {
            
            NSRange relationshipRange = [key rangeOfString:@"relationships."];
            BOOL isRelationship = relationshipRange.location != NSNotFound;
            
            if(isRelationship){
                
                NSString *relationshipKey = [key substringFromIndex: relationshipRange.location+1];
                NSDictionary *relation = (resourceObjectRelationships[relationshipKey] && resourceObjectRelationships[relationshipKey] != [NSNull null]) ? resourceObjectRelationships[relationshipKey] : nil;
                
                if (relation) {
                    
                    NSMutableArray *relatedJSONAPIResources = [NSMutableArray new];
                    id relationData = (relation[@"data"] && relation[@"data"] != [NSNull null]) ? relation[@"data"] : nil;
                    
                    if(relationData){
                        
                        if([relationData isKindOfClass:[NSArray class]]){
                            
                            for (NSDictionary *resourceObjectIdentifier in (NSArray *)relationData) {
                                NSString *type = resourceObjectIdentifier[@"type"];
                                NSString *ID = resourceObjectIdentifier[@"id"];
                                
                                for(JSONAPIResource *relatedResource in self.includedResources){
                                    if([relatedResource.ID isEqualToString: ID] && [relatedResource.type isEqualToString:type])
                                        [relatedJSONAPIResources addObject: relatedResource];
                                }
                            }
                        }
                        else{
                            NSString *type = relationData[@"type"];
                            NSString *ID = relationData[@"id"];
                            
                            for(JSONAPIResource *relatedResource in self.includedResources){
                                if([relatedResource.ID isEqualToString: ID] && [relatedResource.type isEqualToString:type]){
                                    [relatedJSONAPIResources addObject: relatedResource];
                                    break;
                                }
                            }
                        }
                    }
                    else{
                        NSLog(@"JSONAPIResource Warning : relation for key %@ has no data", relationshipKey);
                    }
                    
                    
                    if([relatedJSONAPIResources count] > 0){
                        
                        NSString *property = [userMap objectForKey:relationshipKey];
                        if([self objectForKey: property]){
                            
                            if([[self objectForKey: property] isKindOfClass:[NSArray class]]){
                                [self setValue: relatedJSONAPIResources forKey: property];
                            }
                            else{
                                [self setValue: relatedJSONAPIResources[0] forKey: property];
                            }
                        }
                        else{
                            NSLog(@"JSONAPIResource Warning : object does not define a property of key: %@\n bailing out.", property);
                        }
                    }
                    else{
                        NSLog(@"JSONAPIResource Warning : objects not found for resource of key: %@\n bailing out.", relationshipKey);
                    }
                }
                else {
                    NSLog(@"JSONAPIResource Warning : relation for key %@ not found in json data.", key);
                }
            }
            else{
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

@end

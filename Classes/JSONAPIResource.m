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


- (id)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        [self setWithDictionary:dict];
    }
    return self;
}

- (id)objectForKey:(NSString*)key {
    return [_dictionary objectForKey:key];
}

- (NSDictionary *)mapMembersToProperties {
    return [[NSDictionary alloc] init];
}

- (NSDictionary *) mapRelationshipsToProperties{

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
    
    NSDictionary *userMap = [self mapMembersToProperties];
    if([userMap count]>0){
        
        for (NSString *key in [userMap allKeys]) {
                if ([resourceObjectAttributes objectForKey:key] != nil && [resourceObjectAttributes objectForKey:key] != [NSNull null]) {
                    
                    NSString *property = [userMap objectForKey:key];
                    
                    NSRange formatRange = [property rangeOfString:@":"];
                    
                    @try {
                        if (formatRange.location != NSNotFound) {
                            NSString *formatFunction = [property substringToIndex:formatRange.location];
                            property = [property substringFromIndex:(formatRange.location+1)];
                            
                            [self setValue:[JSONAPIResourceFormatter performFormatBlock:[resourceObjectAttributes objectForKey:key] withName:formatFunction] forKey:property ];
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




@end

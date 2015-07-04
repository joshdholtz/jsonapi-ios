//
//  PeopleResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "PeopleResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"

@implementation PeopleResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"people"];
        
        [__descriptor setIdProperty:@"ID"];

        [__descriptor addProperty:@"firstName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"first-name"]];
        [__descriptor addProperty:@"lastName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"last-name"]];
        [__descriptor addProperty:@"twitter"];
    });

    return __descriptor;
}

@end

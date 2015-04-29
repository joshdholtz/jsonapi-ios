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

static JSONAPIResourceDescriptor *_descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"people"];

        [_descriptor addProperty:@"firstName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"first-name"]];
        [_descriptor addProperty:@"lastName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"last-name"]];
        [_descriptor addProperty:@"twitter"];
    });

    return _descriptor;
}

@end

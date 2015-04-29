//
//  CommentResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "CommentResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"

#import "PeopleResource.h"


@implementation CommentResource

static JSONAPIResourceDescriptor *_descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"comments"];

        [_descriptor addProperty:@"text" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"body"]];
        
        [_descriptor hasOne:[PeopleResource class] withName:@"author"];
    });

    return _descriptor;
}

@end

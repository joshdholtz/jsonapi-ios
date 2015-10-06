//
//  ArticleResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "ArticleResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"
#import "NSDateFormatter+JSONAPIDateFormatter.h"

#import "PeopleResource.h"
#import "CommentResource.h"


@implementation ArticleResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"articles"];
        
        [__descriptor setIdProperty:@"ID"];

        [__descriptor addProperty:@"title"];
        [__descriptor addProperty:@"date"
                 withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"date" withFormat:[NSDateFormatter RFC3339DateFormatter]]];
        
        [__descriptor hasOne:[PeopleResource class] withName:@"author"];
        [__descriptor hasMany:[CommentResource class] withName:@"comments"];
    });
    
    return __descriptor;
}

@end

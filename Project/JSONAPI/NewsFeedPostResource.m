//
//  NewsFeedPostResource.m
//  JSONAPI
//
//  Created by Rafael Kayumov on 13.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "NewsFeedPostResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"
#import "NSDateFormatter+JSONAPIDateFormatter.h"

@implementation NewsFeedPostResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"NewsFeedPost"];
        
        [__descriptor setIdProperty:@"ID"];
        
        [__descriptor addProperty:@"createdAt"
                  withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"created-at" withFormat:[NSDateFormatter RFC3339DateFormatter]]];
        [__descriptor addProperty:@"title"];
        [__descriptor addProperty:@"text"];
        
        [__descriptor hasOne:nil withName:@"publisher"];
        [__descriptor hasMany:nil withName:@"attachments"];
    });
    
    return __descriptor;
}

@end

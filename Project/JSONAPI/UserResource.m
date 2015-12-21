//
//  UserResource.m
//  JSONAPI
//
//  Created by Rafael Kayumov on 13.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "UserResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"

@implementation UserResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"User"];
        
        [__descriptor setIdProperty:@"ID"];
        
        [__descriptor addProperty:@"name"];
        [__descriptor addProperty:@"email"];
    });
    
    return __descriptor;
}

@end

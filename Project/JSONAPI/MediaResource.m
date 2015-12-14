//
//  MediaResource.m
//  JSONAPI
//
//  Created by Rafael Kayumov on 14.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "MediaResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"

@implementation MediaResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"Media"];
        
        [__descriptor setIdProperty:@"ID"];
        
        [__descriptor addProperty:@"mimeType"];
        [__descriptor addProperty:@"fileUrl"];
    });
    
    return __descriptor;
}

@end

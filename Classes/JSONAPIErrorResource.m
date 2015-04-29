//
//  JSONAPIErrorResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 3/17/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIErrorResource.h"

#import "JSONAPIResourceDescriptor.h"

@implementation JSONAPIErrorResource

+ (JSONAPIResourceDescriptor*)descriptor {
    static JSONAPIResourceDescriptor *_descriptor = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"errors"];
        
        [_descriptor addProperty:@"status"];
        [_descriptor addProperty:@"code"];
        [_descriptor addProperty:@"title"];
        [_descriptor addProperty:@"detail"];
        [_descriptor addProperty:@"paths"];
        [_descriptor addProperty:@"links"];
    });
    
    return _descriptor;
}
@end

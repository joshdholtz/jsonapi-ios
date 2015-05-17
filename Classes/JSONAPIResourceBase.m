//
//  JSONAPIResourceBase.m
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong on 5/17/15.
//

#import "JSONAPIResourceBase.h"

@implementation JSONAPIResourceBase

+ (JSONAPIResourceDescriptor *)descriptor {
    // subclass must override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

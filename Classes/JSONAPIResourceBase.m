//
//  JSONAPIResourceBase.m
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import "JSONAPIResourceBase.h"

@implementation JSONAPIResourceBase

+ (JSONAPIResourceDescriptor *)descriptor {
    // subclass must override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

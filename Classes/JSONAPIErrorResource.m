//
//  JSONAPIErrorResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 3/17/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIErrorResource.h"

@implementation JSONAPIErrorResource

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"status" : @"status",
             @"code" : @"code",
             @"title" : @"title",
             @"detail" : @"detail",
             @"paths" : @"paths",
             };
}

@end

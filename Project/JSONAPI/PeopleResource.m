//
//  PeopleResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "PeopleResource.h"

@implementation PeopleResource

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"name" : @"mapName"
             };
}

@end

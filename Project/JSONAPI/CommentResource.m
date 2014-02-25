//
//  CommentResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "CommentResource.h"

@implementation CommentResource

- (NSString *)text {
    return [self objectForKey:@"text"];
}

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"text" : @"mapText"
             };
}

@end

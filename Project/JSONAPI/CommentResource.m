//
//  CommentResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "CommentResource.h"

@implementation CommentResource

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"text" : @"text"
             };
}

@end

//
//  PostResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "PostResource.h"

@implementation PostResource

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"title" : @"title",
             @"date" : @"Date:date",
             @"links.author" : @"author",
             @"links.comments" : @"comments"
             };
}

@end

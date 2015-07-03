//
//  PostResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "PostResource.h"
#import "JSONAPIResourceFormatter.h"

@implementation PostResource

- (NSDictionary *)mapMembersToProperties {
    
    [JSONAPIResourceFormatter registerFormat:@"Date" withBlock:^id(id jsonValue) {
        return [NSDate date];
    }];
    
    return @{
             @"title" : @"title",
             @"date" : @"Date:date"
             };
}

- (NSDictionary *)mapRelationshipsToProperties{

    return @{
             @"author" : @"author",
             @"comments" : @"comments"
             };
}

@end

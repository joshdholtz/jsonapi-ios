//
//  SocialCommunityResource.m
//  JSONAPI
//
//  Created by Rafael Kayumov on 14.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "SocialCommunityResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"

@implementation SocialCommunityResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"SocialCommunity"];
        
        [__descriptor setIdProperty:@"ID"];
        
        [__descriptor addProperty:@"title"];
        [__descriptor addProperty:@"homePage"];
    });
    
    return __descriptor;
}

@end

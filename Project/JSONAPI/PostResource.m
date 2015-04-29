//
//  PostResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "PostResource.h"

#import "JSONAPIPropertyDescriptor.h"
#import "JSONAPIResourceDescriptor.h"
#import "NSDateFormatter+JSONAPIDateFormatter.h"

#import "PeopleResource.h"
#import "CommentResource.h"


@implementation PostResource

static JSONAPIResourceDescriptor *_descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"posts"];
    
    [_descriptor addProperty:@"title"];
    [_descriptor addProperty:@"date"
             withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"date" withFormat:[NSDateFormatter RFC3339DateFormatter]]];
    
    [_descriptor hasOne:[PeopleResource class] withName:@"author"];
    [_descriptor hasMany:[CommentResource class] withName:@"comments"];
  });
  
  return _descriptor;
}

@end

//
//  PostResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

@class CommentResource;
@class PeopleResource;

@interface PostResource : JSONAPIResource

- (PeopleResource*)author;
- (NSArray*)comments;
- (NSString*)name;

@end

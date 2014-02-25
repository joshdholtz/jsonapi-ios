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

@property (nonatomic, strong) NSString *mapName;
@property (nonatomic, strong) PeopleResource *mapAuthor;
@property (nonatomic, strong) NSArray *mapComments;

- (PeopleResource*)author;
- (NSArray*)comments;
- (NSString*)name;

@end

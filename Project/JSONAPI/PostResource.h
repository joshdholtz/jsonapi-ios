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

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) PeopleResource *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *comments;

@end

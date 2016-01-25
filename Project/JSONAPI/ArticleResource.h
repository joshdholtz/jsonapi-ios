//
//  ArticleResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceBase.h"
#import "JSONAPIResourceCollection.h"

@class PeopleResource;

@interface ArticleResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) PeopleResource *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) JSONAPIResourceCollection *comments;

@property (nonatomic, strong) NSArray *versions;

@end

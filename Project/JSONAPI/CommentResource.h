//
//  CommentResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

@interface CommentResource : JSONAPIResource

@property (nonatomic, strong) NSString *mapText;

- (NSString*)text;

@end

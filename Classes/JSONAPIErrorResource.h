//
//  JSONAPIErrorResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 3/17/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

@interface JSONAPIErrorResource : JSONAPIResource

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSArray *paths;

@end

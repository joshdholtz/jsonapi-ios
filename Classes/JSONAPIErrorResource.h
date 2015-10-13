//
//  JSONAPIErrorResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 3/17/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class respresentation of a JSON-API error structure.
 */
@interface JSONAPIErrorResource : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSArray *paths;

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;

@end

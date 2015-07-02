//
//  JSONAPIResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONAPI;

@interface JSONAPIResource : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSDictionary *links;
@property (nonatomic, strong) NSDictionary *relationships;

+ (id)jsonAPIResource:(NSDictionary*)dictionary;
+ (NSArray*)jsonAPIResources:(NSArray*)array;

- (id)initWithDictionary:(NSDictionary*)dict;

- (NSDictionary *)mapKeysToProperties;
- (void)linkWithIncluded:(JSONAPI*)jsonAPI;

@end

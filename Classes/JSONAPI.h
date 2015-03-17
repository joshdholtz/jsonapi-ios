//
//  JSONAPI.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONAPIResource.h"
#import "JSONAPIResourceFormatter.h"
#import "JSONAPIResourceLinker.h"
#import "JSONAPIResourceModeler.h"

@interface JSONAPI : NSObject

@property (nonatomic, strong, readonly) NSDictionary *meta;
@property (nonatomic, strong, readonly) id data;
@property (nonatomic, strong, readonly) NSArray *errors;

@property (readonly) id resource;
@property (nonatomic, strong, readonly) NSArray *resources;

@property (nonatomic, strong, readonly) NSError *internalError;

// Initializers
+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)jsonAPIWithString:(NSString *)string;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithString:(NSString*)string;

@end

//
//  JSONAPI.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONAPIResource.h"

/**
 *  Represents a complete JSON-API formatted message body.
 */
@interface JSONAPI : NSObject

/**
 *  Returns Content-Type string for JSON-API
 *
 *  @return Content-Type string for JSON-API
 */
+ (NSString*)MEDIA_TYPE;

@property (readonly) NSDictionary *meta;
@property (nonatomic, strong, readonly) NSArray *errors;

@property (readonly) id resource;
@property (nonatomic, strong, readonly) NSArray *resources;
@property (nonatomic, strong, readonly) NSDictionary *includedResources;

@property (nonatomic, strong, readonly) NSError *internalError;

// Initializers
+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)jsonAPIWithString:(NSString *)string;
+ (instancetype)jsonAPIWithResource:(NSObject <JSONAPIResource> *)resource;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithString:(NSString*)string;

- (NSDictionary*)dictionary;

- (id)includedResource:(id)ID withType:(NSString*)type;
- (BOOL)hasErrors;

@end

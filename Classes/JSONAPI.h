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
#import "JSONAPIResourceModeler.h"
#import "JSONAPIErrorResource.h"

@interface JSONAPI : NSObject


//mandatory members
@property (nonatomic, strong, readonly) NSDictionary *meta;
@property (nonatomic, strong, readonly) id data;
@property (nonatomic, strong, readonly) NSArray *errors;

//optional members
@property (nonatomic, strong, readonly) NSDictionary *jsonApi;
@property (nonatomic, strong, readonly) NSArray *links;
@property (nonatomic, strong, readonly) NSArray *included;


@property (nonatomic, strong, readonly) NSError *internalError;

// Initializers
+ (instancetype)jsonAPIWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)jsonAPIWithString:(NSString *)string;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithString:(NSString*)string;

- (id)includedResource:(id)ID withType:(NSString*)type;
- (BOOL)hasErrors;

@end

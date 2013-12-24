//
//  JSONAPI.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONAPIResource.h"
#import "JSONAPIResourceLinker.h"

@interface JSONAPI : NSObject

@property (nonatomic, strong) NSDictionary *meta;
@property (nonatomic, strong) NSDictionary *linked;
@property (nonatomic, strong) NSError *error;

- (id)initWithString:(NSString*)string;
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)objectForKey:(NSString*)key;
- (JSONAPIResource*)resourceForKey:(NSString*)key;
- (NSArray*)resourcesForKey:(NSString*)key;

@end

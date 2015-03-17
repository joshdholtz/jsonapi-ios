//
//  JSONAPIResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResource : NSObject<NSCopying, NSCoding>

@property (nonatomic, strong) id ID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *links;

+ (id)jsonAPIResource:(NSDictionary*)dictionary;
+ (NSArray*)jsonAPIResources:(NSArray*)array;

- (NSDictionary *)mapKeysToProperties;

@end

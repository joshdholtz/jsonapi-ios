//
//  JSONAPIResourceFormatter.h
//  JSONAPI
//
//  Created by Josh Holtz on 7/9/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResourceFormatter : NSObject

+ (void)registerFormat:(NSString*)name withBlock:(id(^)(id jsonValue))block;
+ (id)performFormatBlock:(NSString*)value withName:(NSString*)name;

@end

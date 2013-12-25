//
//  JSONAPiResourceLinker.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResourceLinker : NSObject

@property (nonatomic, strong) NSMutableDictionary *linkedTypeToLinksType;

+ (void)link:(NSString*)resourceLinkType toLinkedType:(NSString*)linkedType;
+ (NSString*)linkedType:(NSString*)resourceLinkType;

+ (void)unlinkAll;

@end

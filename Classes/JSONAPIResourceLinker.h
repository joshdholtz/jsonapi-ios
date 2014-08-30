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

+ (instancetype)defaultInstance;

+ (void)link:(NSString*)resourceLinkType toLinkedType:(NSString*)linkedType __deprecated;
+ (NSString*)linkedType:(NSString*)resourceLinkType __deprecated;

+ (void)unlinkAll __deprecated;

- (void)link:(NSString*)resourceLinkType toLinkedType:(NSString*)linkedType;
- (NSString*)linkedType:(NSString*)resourceLinkType;

- (void)unlinkAll;

@end

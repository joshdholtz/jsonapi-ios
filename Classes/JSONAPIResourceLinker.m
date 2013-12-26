//
//  JSONAPiResourceLinker.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceLinker.h"

@implementation JSONAPIResourceLinker

+ (instancetype)sharedLinker {
    static JSONAPIResourceLinker *_sharedLinker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLinker = [[JSONAPIResourceLinker alloc] init];
    });
    
    return _sharedLinker;
}

- (id)init {
    self = [super init];
    if (self) {
        self.linkedTypeToLinksType = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (void)link:(NSString*)resourceLinkType toLinkedType:(NSString*)linkedType {
    [[JSONAPIResourceLinker sharedLinker].linkedTypeToLinksType setObject:linkedType forKey:resourceLinkType];
}

+ (NSString*)linkedType:(NSString*)resourceLinkType {
    NSString *type = [[JSONAPIResourceLinker sharedLinker].linkedTypeToLinksType objectForKey:resourceLinkType];
    if (type == nil) {
        type = resourceLinkType;
    }
    
    return type;
}

+ (void)unlinkAll {
    [[JSONAPIResourceLinker sharedLinker].linkedTypeToLinksType removeAllObjects];
}

- (void)link:(NSString*)resourceLinkType toLinked:(NSString*)linkedType {
    [self.linkedTypeToLinksType setObject:linkedType forKey:resourceLinkType];
}

- (NSString*)linkedType:(NSString*)resourceLinkType {
    return [self.linkedTypeToLinksType objectForKey:resourceLinkType];
}

@end

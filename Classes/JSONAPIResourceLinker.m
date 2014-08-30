//
//  JSONAPiResourceLinker.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceLinker.h"

@implementation JSONAPIResourceLinker

+ (instancetype)defaultInstance {
    static JSONAPIResourceLinker *_defaultInstance = nil;
    if (!_defaultInstance) {
        _defaultInstance = [[JSONAPIResourceLinker alloc] init];
    }
    
    return _defaultInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.linkedTypeToLinksType = @{}.mutableCopy;
    }
    return self;
}

+ (void)link:(NSString*)resourceLinkType toLinkedType:(NSString*)linkedType {
    [[JSONAPIResourceLinker defaultInstance] link:resourceLinkType toLinkedType:linkedType];
}

+ (NSString*)linkedType:(NSString*)resourceLinkType {
    return [[JSONAPIResourceLinker defaultInstance] linkedType:resourceLinkType];
}

+ (void)unlinkAll {
    [[JSONAPIResourceLinker defaultInstance] unlinkAll];
}

- (void)link:(NSString*)resourceLinkType toLinkedType:(NSString*)linkedType {
    (self.linkedTypeToLinksType)[resourceLinkType] = linkedType;
}

- (NSString*)linkedType:(NSString*)resourceLinkType {
    NSString *type = (self.linkedTypeToLinksType)[resourceLinkType];
    if (type == nil) {
        type = resourceLinkType;
    }
    
    return type;
}

- (void)unlinkAll {
    [self.linkedTypeToLinksType removeAllObjects];
}

@end

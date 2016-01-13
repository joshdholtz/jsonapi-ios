//
//  JSONAPIResourceCollection.m
//  JSONAPI
//
//  Created by Julian Krumow on 13.01.16.
//  Copyright © 2016 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceCollection.h"

@interface JSONAPIResourceCollection ()

@end

@implementation JSONAPIResourceCollection

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _resources = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _resources = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    JSONAPIResourceCollection *copy = [JSONAPIResourceCollection new];
    copy.selfLink = self.selfLink.copy;
    copy.related = self.related.copy;
    copy.resources = self.resources.mutableCopy;
    return copy;
}

@end

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
    copy.relatedLink = self.relatedLink.copy;
    copy.resources = self.resources.mutableCopy;
    return copy;
}

- (id)firstObject
{
    return self.resources.firstObject;
}
- (id)lastObject
{
    return self.resources.lastObject;
}

- (NSUInteger)count
{
    return self.resources.count;
}

- (void)addObject:(id)object
{
    [self.resources addObject:object];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.resources[idx];
}
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    self.resources[idx] = obj;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self.resources enumerateObjectsUsingBlock:block];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])stackbuf
                                    count:(NSUInteger)len
{
    return [self.resources countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end

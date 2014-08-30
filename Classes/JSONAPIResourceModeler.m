//
//  JSONAPIResourceModeler.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceModeler.h"

#import "JSONAPI.h"

@implementation JSONAPIResourceModeler

+ (instancetype)defaultInstance {
    static JSONAPIResourceModeler *_defaultInstance = nil;
    if (!_defaultInstance) {
         _defaultInstance = [[JSONAPIResourceModeler alloc] init];
    }
    
    return _defaultInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.resourceToLinkedType = @{}.mutableCopy;
    }
    return self;
}

+ (void)useResource:(Class)jsonApiResource toLinkedType:(NSString *)linkedType {
    [[JSONAPIResourceModeler defaultInstance].resourceToLinkedType setValue:jsonApiResource forKey:linkedType];
}

+ (Class)resourceForLinkedType:(NSString *)linkedType {
    return [[JSONAPIResourceModeler defaultInstance].resourceToLinkedType valueForKey:linkedType];
}

+ (void)unmodelAll {
    [[JSONAPIResourceModeler defaultInstance].resourceToLinkedType removeAllObjects];
}

- (void)useResource:(Class)jsonApiResource toLinkedType:(NSString *)linkedType {
    [self.resourceToLinkedType setValue:jsonApiResource forKey:linkedType];
}

- (Class)resourceForLinkedType:(NSString *)linkedType {
    Class c = [self.resourceToLinkedType valueForKey:linkedType];

#ifndef NDEBUG
    if ([JSONAPI isDebuggingEnabled]) {
        NSLog(@"Warning: Class not defined for '%@' (%@)", linkedType, NSStringFromSelector(_cmd));
    }
#endif
    
    return c;
}

- (void)unmodelAll {
    [self.resourceToLinkedType removeAllObjects];
}

@end

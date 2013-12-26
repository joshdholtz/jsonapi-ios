//
//  JSONAPIResourceModeler.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceModeler.h"

@implementation JSONAPIResourceModeler

+ (instancetype)sharedModeler {
    static JSONAPIResourceModeler *_sharedModeler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModeler = [[JSONAPIResourceModeler alloc] init];
    });
    
    return _sharedModeler;
}

- (id)init {
    self = [super init];
    if (self) {
        self.resourceToLinkedType = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (void)useResource:(Class)jsonApiResource toLinkedType:(NSString *)linkedType {
    [[JSONAPIResourceModeler sharedModeler].resourceToLinkedType setValue:jsonApiResource forKey:linkedType];
}

+ (Class)resourceForLinkedType:(NSString *)linkedType {
    return [[JSONAPIResourceModeler sharedModeler].resourceToLinkedType valueForKey:linkedType];
}

+ (void)unmodelAll {
    [[JSONAPIResourceModeler sharedModeler].resourceToLinkedType removeAllObjects];
}

@end

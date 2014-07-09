//
//  JSONAPIResourceFormatter.m
//  JSONAPI
//
//  Created by Josh Holtz on 7/9/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceFormatter.h"

@interface JSONAPIResourceFormatter()

@property (nonatomic, strong) NSMutableDictionary *formatBlocks;

@end

@implementation JSONAPIResourceFormatter

+ (instancetype)sharedFormatter {
    static JSONAPIResourceFormatter *_sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[JSONAPIResourceFormatter alloc] init];
    });
    
    return _sharedFormatter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.formatBlocks = @{}.mutableCopy;
    }
    return self;
}

+ (void)registerFormat:(NSString*)name withBlock:(id(^)(id jsonValue))block {
    [[JSONAPIResourceFormatter sharedFormatter].formatBlocks setObject:[block copy] forKey:name];
}

+ (id)performFormatBlock:(NSString*)value withName:(NSString*)name {
    id(^block)(NSString *);
    block = [[JSONAPIResourceFormatter sharedFormatter].formatBlocks objectForKey:name];
    if (block != nil) {
        return block(value);
    } else {
        return nil;
    }
}

@end

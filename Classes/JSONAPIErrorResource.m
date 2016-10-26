//
//  JSONAPIErrorResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 3/17/15.
//  Copyright (c) 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIErrorResource.h"

#import "JSONAPIResourceDescriptor.h"

@implementation JSONAPIErrorResource

- (instancetype) initWithDictionary:(NSDictionary*)dictionary {
    self =  [self init];
    
    if (self) {
        _ID = dictionary[@"id"];
        _href = dictionary[@"href"];
        _status = dictionary[@"status"];
        _code = dictionary[@"code"];
        _title = dictionary[@"title"];
        _detail = dictionary[@"detail"];
        _links = dictionary[@"links"];
        _paths = dictionary[@"paths"];
        _source = dictionary[@"source"];
    }
    
    return self;
}

- (NSString *)pointer
{
    if (self.source) {
        return self.source[@"pointer"];;
    }
    
    return nil;
}

- (NSString *)parameter
{
    if (self.source) {
        return self.source[@"parameter"];
    }
    
    return nil;
}

@end

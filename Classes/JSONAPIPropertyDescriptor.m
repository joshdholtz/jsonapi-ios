//
//  JSONAPIProperty.m
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import "JSONAPIPropertyDescriptor.h"

@implementation JSONAPIPropertyDescriptor

- (instancetype)initWithJsonName:(NSString*)name {
  return [self initWithJsonName:name withFormat:nil];
}

- (instancetype)initWithJsonName:(NSString*)name withFormat:(NSFormatter*)fmt {
  self = [self init];
  
  if (self) {
    _jsonName = name;
    _formatter = fmt;
    _resourceType = nil;
  }
  
  return self;
}

- (instancetype)initWithJsonName:(NSString*)name withResource:(Class)resource {
  self = [self init];
  
  if (self) {
    _jsonName = name;
    _formatter = nil;
    _resourceType = resource;
  }
  
  return self;
}

@end

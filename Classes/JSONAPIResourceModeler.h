//
//  JSONAPIResourceModeler.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResourceModeler : NSObject

@property (nonatomic, strong) NSMutableDictionary *resourceToLinkedType;

+ (instancetype)defaultInstance;

+ (void)useResource:(Class)jsonApiResource toLinkedType:(NSString*)linkedType __deprecated;
+ (Class)resourceForLinkedType:(NSString*)linkedType __deprecated;

+ (void)unmodelAll __deprecated;

- (void)useResource:(Class)jsonApiResource toLinkedType:(NSString*)linkedType;
- (Class)resourceForLinkedType:(NSString*)linkedType;

- (void)unmodelAll;

@end

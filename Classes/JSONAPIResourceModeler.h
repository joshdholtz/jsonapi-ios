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

+ (void)useResource:(Class)jsonApiResource toLinkedType:(NSString*)linkedType;
+ (Class)resourceForLinkedType:(NSString*)linkedType;

+ (void)unmodelAll;

@end

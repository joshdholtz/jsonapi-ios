//
//  JSONAPIResourceCollection.h
//  JSONAPI
//
//  Created by Julian Krumow on 13.01.16.
//  Copyright © 2016 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIResourceCollection : NSObject

@property (nonatomic) NSMutableArray *resources;
@property (nonatomic) NSString *selfLink;
@property (nonatomic) NSString *related;

- (instancetype)initWithArray:(NSArray *)array;

- (id)firstObject;
- (id)lastObject;

- (NSUInteger)count;
- (void)addObject:(id)object;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])stackbuf
                                    count:(NSUInteger)len;
@end

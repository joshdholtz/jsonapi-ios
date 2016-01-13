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
@end

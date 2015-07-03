//
//  JSONAPITests.m
//  JSONAPITests
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONAPI.h"
#import "JSONAPIErrorResource.h"

#import "CommentResource.h"
#import "PeopleResource.h"
#import "PostResource.h"

@interface JSONAPITests : XCTestCase

@end

@implementation JSONAPITests

- (void)setUp {
    [super setUp];

    [JSONAPIResourceModeler useResource:[CommentResource class] toLinkedType:@"comments"];
    [JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"people"];
    [JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testDuringDevelopmentJustToDebugForgiveMe{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"main_example" ofType:@"json"];
    NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    JSONAPI *api = [JSONAPI jsonAPIWithString: jsonStr];
    PostResource *res = (PostResource *) api.data;
    
}

#pragma mark - Private

- (NSDictionary*)mainExampleJSON {
    return [self jsonFor:@"main_example" ofType:@"json"];
}

- (NSDictionary*)errorExampleJSON {
    return [self jsonFor:@"error_example" ofType:@"json"];
}

- (NSDictionary*)jsonFor:(NSString*)resource ofType:(NSString*)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

@end

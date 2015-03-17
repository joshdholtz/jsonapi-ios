//
//  JSONAPITests.m
//  JSONAPITests
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONAPI.h"

#import "PostResource.h"

@interface JSONAPITests : XCTestCase

@end

@implementation JSONAPITests

- (void)setUp {
    [super setUp];

    [JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMeta {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
    
    XCTAssertNotNil(jsonAPI.meta, @"Meta should not be nil");
    XCTAssertEqualObjects(jsonAPI.meta[@"hehe"], @"hoho", @"Meta's 'hehe' should equal 'hoho'");
}

- (void)testDataPosts {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
    
    XCTAssertNotNil(jsonAPI.resource, @"Resource should not be nil");
    XCTAssertNotNil(jsonAPI.resources, @"Resources should not be nil");
    XCTAssertEqual(jsonAPI.resources.count, 1, @"Resources should contain 1 resource");
    
    PostResource *post = jsonAPI.resource;
    XCTAssert([post isKindOfClass:[PostResource class]], @"Post should be a PostResource");
    XCTAssertEqualObjects(post.ID, @"1", @"Post id should be 1");
    XCTAssertEqualObjects(post.title, @"JSON API paints my bikeshed!", @"Post title should be 'JSON API paints my bikeshed!'");
}

#pragma mark - Private

- (NSDictionary*)mainExampleJSON {
    return [self jsonFor:@"main_example" ofType:@"json"];
}

- (NSDictionary*)jsonFor:(NSString*)resource ofType:(NSString*)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    return [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

@end

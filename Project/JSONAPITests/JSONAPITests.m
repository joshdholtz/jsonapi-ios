//
//  JSONAPITests.m
//  JSONAPITests
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONAPI.h"
#import "JSONAPIResourceDescriptor.h"
#import "JSONAPIErrorResource.h"
#import "JSONAPIResourceParser.h"

#import "CommentResource.h"
#import "PeopleResource.h"
#import "ArticleResource.h"

@interface JSONAPITests : XCTestCase

@end

@implementation JSONAPITests

- (void)setUp {
    [super setUp];

    [JSONAPIResourceDescriptor addResource:[CommentResource class]];
    [JSONAPIResourceDescriptor addResource:[PeopleResource class]];
    [JSONAPIResourceDescriptor addResource:[ArticleResource class]];
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

- (void)testDataArticles {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
    
    XCTAssertNotNil(jsonAPI.resource, @"Resource should not be nil");
    XCTAssertNotNil(jsonAPI.resources, @"Resources should not be nil");
    XCTAssertEqual(jsonAPI.resources.count, 1, @"Resources should contain 1 resource");
    
    ArticleResource *article = jsonAPI.resource;
    XCTAssert([article isKindOfClass:[ArticleResource class]], @"Article should be a ArticleResource");
    XCTAssertEqualObjects(article.ID, @"1", @"Article id should be 1");
    XCTAssertEqualObjects(article.title, @"JSON API paints my bikeshed!", @"Article title should be 'JSON API paints my bikeshed!'");
}

- (void)testIncludedPeopleAndComments {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
    
    XCTAssertNotNil(jsonAPI.includedResources, @"Included resources should not be nil");
    XCTAssertEqual(jsonAPI.includedResources.count, 2, @"Included resources should contain 2 types");
    
}

- (void)testDataArticleAuthorAndComments {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
	
    ArticleResource *article = jsonAPI.resource;
    CommentResource *firstComment = article.comments.firstObject;
    
    XCTAssertNotNil(article.author, @"Article's author should not be nil");
    XCTAssertNotNil(article.comments, @"Article's comments should not be nil");
    XCTAssertEqual(article.comments.count, 2, @"Article should contain 2 comments");
    XCTAssertEqualObjects(article.author.firstName, @"Dan", @"Article's author firstname should be 'Dan'");
    XCTAssertEqualObjects(firstComment.text, @"First!", @"Article's first comment should be 'First!'");
    XCTAssertEqualObjects(firstComment.author.firstName, @"Dan", @"Article's first comment author should be 'Dan'");
}

- (void)testIncludedCommentIsLinked {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
    
    CommentResource *comment = [jsonAPI includedResource:@"5" withType:@"comments"];
    XCTAssertNotNil(comment.author, @"Comment's author should not be nil");
    XCTAssertEqualObjects(comment.author.ID, @"9", @"Comment's author's ID should be 2");
}

- (void)testNoError {
    NSDictionary *json = [self mainExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
 
    XCTAssertFalse([jsonAPI hasErrors], @"JSON API should not have errors");
}

- (void)testError {
    NSDictionary *json = [self errorExampleJSON];
    JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];
    
    XCTAssertTrue([jsonAPI hasErrors], @"JSON API should have errors");
    
    JSONAPIErrorResource *error = jsonAPI.errors.firstObject;
    XCTAssertEqualObjects(error.ID, @"123456", @"Error id should be 123456");
}

- (void)testSerializeSimple {
    PeopleResource *newAuthor = [[PeopleResource alloc] init];
    
    newAuthor.firstName = @"Karl";
    newAuthor.lastName = @"Armstrong";
    
    NSDictionary *json = [JSONAPIResourceParser dictionaryFor:newAuthor];
    XCTAssertEqualObjects(json[@"type"], @"people", @"Did not create person!");
    XCTAssertEqualObjects(json[@"attributes"][@"first-name"], @"Karl", @"Wrong first name!");
    XCTAssertNil(json[@"attributes"][@"twitter"], @"Wrong Twitter!.");
}

- (void)testSerializeWithFormat {
    ArticleResource *newArticle = [[ArticleResource alloc] init];
    newArticle.title = @"Title";
    newArticle.date = [NSDate date];
    
    NSDictionary *json = [JSONAPIResourceParser dictionaryFor:newArticle];
    XCTAssertEqualObjects(json[@"type"], @"articles", @"Did not create article!");
    XCTAssertNotNil(json[@"attributes"][@"date"], @"Wrong date!");
    XCTAssertTrue([json[@"attributes"][@"date"] isKindOfClass:[NSString class]], @"Date should be string!.");
}

- (void)testSerializeComplex {
    PeopleResource *newAuthor = [[PeopleResource alloc] init];
    
    newAuthor.ID = [NSUUID UUID];
    newAuthor.firstName = @"Karl";
    newAuthor.lastName = @"Armstrong";
    
    CommentResource *newComment = [[CommentResource alloc] init];
    newComment.ID = [NSUUID UUID];
    newComment.author = newAuthor;
    newComment.text = @"First!";
    
    ArticleResource *newArticle = [[ArticleResource alloc] init];
    newArticle.title = @"Title";
    newArticle.author = newAuthor;
    newArticle.date = [NSDate date];
    newArticle.comments = [[NSArray alloc] initWithObjects:newComment, nil];
    
    NSDictionary *json = [JSONAPIResourceParser dictionaryFor:newArticle];
    XCTAssertEqualObjects(json[@"type"], @"articles", @"Did not create Article!");
    XCTAssertNotNil(json[@"relationships"], @"Did not create links!");
    XCTAssertNotNil(json[@"relationships"][@"author"], @"Did not create links!");
    XCTAssertNotNil(json[@"relationships"][@"author"][@"data"], @"Did not create links!");
    XCTAssertEqualObjects(json[@"relationships"][@"author"][@"data"][@"id"], newAuthor.ID, @"Wrong link ID!.");
    XCTAssertNil(json[@"relationships"][@"author"][@"first-name"], @"Bad link!");

    XCTAssertNotNil(json[@"relationships"][@"comments"], @"Did not create links!");
    XCTAssertTrue([json[@"relationships"][@"comments"] isKindOfClass:[NSArray class]], @"Comments should be array!.");
    XCTAssertEqual([json[@"relationships"][@"comments"] count], 1, @"Comments should have 1 element!.");
}

- (void)testCreate {
  PeopleResource *newAuthor = [[PeopleResource alloc] init];
  
  newAuthor.firstName = @"Karl";
  newAuthor.lastName = @"Armstrong";
  
  JSONAPI *jsonAPI = [JSONAPI jsonAPIWithResource:newAuthor];
  XCTAssertEqualObjects([jsonAPI dictionary][@"data"][@"type"], @"people", @"Did not create person!");
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

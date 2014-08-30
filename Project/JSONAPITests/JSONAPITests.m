//
//  JSONAPITests.m
//  JSONAPITests
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONAPI.h"

#import "CommentResource.h"
#import "PeopleResource.h"
#import "PostResource.h"

@interface JSONAPITests : XCTestCase

@end

@implementation JSONAPITests

- (void)setUp
{
    [super setUp];
    
    [JSONAPI setIsDebuggingEnabled:TRUE];

    [[JSONAPIResourceLinker defaultInstance] link:@"author" toLinkedType:@"authors"];
    [[JSONAPIResourceLinker defaultInstance] link:@"authors" toLinkedType:@"authors"]; // Don't NEED this but why not be explicit
    [[JSONAPIResourceLinker defaultInstance] link:@"person" toLinkedType:@"people"];
    [[JSONAPIResourceLinker defaultInstance] link:@"chapter" toLinkedType:@"chapters"];
    [[JSONAPIResourceLinker defaultInstance] link:@"book" toLinkedType:@"books"];
    
    [[JSONAPIResourceModeler defaultInstance] useResource:[CommentResource class] toLinkedType:@"comment"];
    [[JSONAPIResourceModeler defaultInstance] useResource:[PeopleResource class] toLinkedType:@"authors"];
    [[JSONAPIResourceModeler defaultInstance] useResource:[PeopleResource class] toLinkedType:@"people"];
    [[JSONAPIResourceModeler defaultInstance] useResource:[PostResource class] toLinkedType:@"posts"];
}

- (void)tearDown
{
    [[JSONAPIResourceLinker defaultInstance] unlinkAll];
    [[JSONAPIResourceModeler defaultInstance] unmodelAll];
    [[JSONAPIResourceFormatter defaultInstance] unregisterAll];
    
    [super tearDown];
}

- (void)testLinkingCommentResource
{
    NSString *linkedType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"comment"];
    NSLog(@"linkedType: %@", linkedType);
    Class c = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:linkedType];
    NSString *type = NSStringFromClass(c);
    NSLog(@"type: %@", type);
 
    XCTAssert([@"CommentResource" isEqualToString:type], @"CommentResource is expected");
}

- (void)testLinkingPeopleResource
{
    NSString *linkedType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"authors"];
    NSLog(@"linkedType: %@", linkedType);
    Class c = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:linkedType];
    NSString *type = NSStringFromClass(c);
    NSLog(@"type: %@", type);
    
    XCTAssert([@"PeopleResource" isEqualToString:type], @"PeopleResource is expected");
}

- (void)testLinkingPostResource
{
    NSString *linkedType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"posts"];
    NSLog(@"linkedType: %@", linkedType);
    Class c = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:linkedType];
    NSString *type = NSStringFromClass(c);
    NSLog(@"type: %@", type);
    
    XCTAssert([@"PostResource" isEqualToString:type], @"PostResource is expected");
}

- (void)testMeta
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    XCTAssert([meta isEqualToDictionary:jsonAPI.meta], @"Meta does not equal %@", meta);
    
}

- (void)testBadMeta
{
    NSArray *meta = @[ @{ @"page_number" : @1, @"number_of_pages" : @5} ];
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    XCTAssertNil(jsonAPI.meta, @"Meta is not nil");
    
}

- (void)testLinkedCount
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    XCTAssert(linked.count == jsonAPI.linked.count, @"Linked count does not equal %lu", (unsigned long)linked.count);
    
}

- (void)testLinkedResource {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linked = @{ @"authors" : @[ linkedAuthor9 ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *linkedAuthorResource = (jsonAPI.linked)[@"authors"][@9];
    XCTAssertEqualObjects(linkedAuthor9[@"id"], linkedAuthorResource.ID , @"Author resource ID does not equal %@", linkedAuthor9[[[@"id"]]]);
    XCTAssertEqualObjects(linkedAuthor9[@"name"], [linkedAuthorResource objectForKey:@"name"] , @"Author resource name does not equal %@", linkedAuthor9[[[@"name"]]]);
}

- (void)testBadLinked
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSArray *linked = @[ @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] } ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSLog(@"%lu HRM %d", (unsigned long)jsonAPI.linked.count, 0);
    XCTAssert(jsonAPI.linked.count == 0, @"Linked is not 0");
    
}

- (void)testResourcesCount {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    XCTAssert(posts.count == [jsonAPI resourcesForKey:@"posts"].count, @"Posts count does not equal %lu", (unsigned long)posts.count);
}

- (void)testResourcesObject {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];

    XCTAssertEqualObjects(post[@"id"], resource.ID, @"Posts ID does not equal %@", post[[[@"id"]]]);
    XCTAssertEqualObjects(post[@"name"], [resource objectForKey:@"name"], @"Posts name does not equal %@", post[[[@"name"]]]);
}

- (void)testResourcesObjectWithStringId {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @"9", @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @"9" } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];
    
    XCTAssertEqualObjects(post[@"id"], resource.ID, @"Posts ID does not equal %@", post[[[@"id"]]]);
    XCTAssertEqualObjects(post[@"name"], [resource objectForKey:@"name"], @"Posts name does not equal %@", post[[[@"name"]]]);
}

- (void)testResourceObjectsWithArrayOfStringIds {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @"9", @"name" : @"Josh" };
    NSDictionary *linkedAuthor11 = @{ @"id" : @"11", @"name" : @"Bandit" };
    NSArray *linkedAuthors = @[ linkedAuthor9, linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"authors" : @[ @"9", @"11" ] } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];
    
    NSArray *linkedAuthorsResources = [resource linkedResourceForKey:@"authors"];
    JSONAPIResource *linkedAuthorResource9, *linkedAuthorResource11;
    for (JSONAPIResource *linkedAuthorResource in linkedAuthorsResources) {
        if ([linkedAuthorResource.ID isEqualToString:linkedAuthor9[@"id"]] == YES) {
            linkedAuthorResource9 = linkedAuthorResource;
        } else if ([linkedAuthorResource.ID isEqualToString:linkedAuthor11[@"id"]] == YES) {
            linkedAuthorResource11 = linkedAuthorResource;
        }
    }

    XCTAssert(linkedAuthorsResources.count == linkedAuthors.count, @"Linked author resource count is not %lu", (unsigned long)linkedAuthors.count);
    
    XCTAssertEqualObjects([linkedAuthorResource9 objectForKey:@"name"], linkedAuthor9[@"name"], @"Linked author's 9 name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    
    XCTAssertEqualObjects([linkedAuthorResource11 objectForKey:@"name"], linkedAuthor11[@"name"], @"Linked author's 11 name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    
}

- (void)testResourceLinkSameTypeName {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linked = @{ @"authors" : @[ linkedAuthor9 ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];
    
    NSLog(@"Linked Resources: %@", resource.linkedResources);
    
    JSONAPIResource *linkedAuthor = [resource linkedResourceForKey:@"author"];
    
    XCTAssertNotNil(linkedAuthor, @"Linked author is nil");
    XCTAssertEqualObjects([linkedAuthor objectForKey:@"name"], linkedAuthor9[@"name"], @"Linked author's name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    XCTAssertEqualObjects([linkedAuthor objectForKey:@"name"], linkedAuthor9[@"name"], @"Linked author's name is not equal to %@", linkedAuthor9[[[@"name"]]]);
}

- (void)testResourceLinksSameTypeName {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linkedAuthor11 = @{ @"id" : @11, @"name" : @"Bandit" };
    NSArray *linkedAuthors = @[ linkedAuthor9, linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"authors" : @[ @9, @11 ] } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];
    
    NSArray *linkedAuthorsResources = [resource linkedResourceForKey:@"authors"];
    JSONAPIResource *linkedAuthorResource9, *linkedAuthorResource11;
    for (JSONAPIResource *linkedAuthorResource in linkedAuthorsResources) {
        if ([linkedAuthorResource.ID isEqualToNumber:linkedAuthor9[@"id"]] == YES) {
            linkedAuthorResource9 = linkedAuthorResource;
        } else if ([linkedAuthorResource.ID isEqualToNumber:linkedAuthor11[@"id"]] == YES) {
            linkedAuthorResource11 = linkedAuthorResource;
        }
    }
    
    XCTAssert(linkedAuthorsResources.count == linkedAuthors.count, @"Linked author resource count is not %lu", (unsigned long)linkedAuthors.count);
    
    XCTAssertEqualObjects([linkedAuthorResource9 objectForKey:@"name"], linkedAuthor9[@"name"], @"Linked author's 9 name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    XCTAssertEqualObjects([linkedAuthorResource9 objectForKey:@"name"], linkedAuthor9[@"name"], @"Linked author's 9 name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    
    XCTAssertEqualObjects([linkedAuthorResource11 objectForKey:@"name"], linkedAuthor11[@"name"], @"Linked author's 11 name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    XCTAssertEqualObjects([linkedAuthorResource11 objectForKey:@"name"], linkedAuthor11[@"name"], @"Linked author's 11 name is not equal to %@", linkedAuthor9[[[@"name"]]]);
    
}

- (void)testResourceLinksRealDifferentTypeName {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedPeople9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linkedPeople11 = @{ @"id" : @11, @"name" : @"Bandit" };
    NSArray *linkedPeople = @[ linkedPeople9, linkedPeople11 ];
    NSDictionary *linked = @{ @"people" : linkedPeople };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"person" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];
    
    JSONAPIResource *linkedPersonResource = [resource linkedResourceForKey:@"person"];
    
    XCTAssertNotNil(linkedPersonResource, @"Linked person is nil");
    XCTAssertEqualObjects([linkedPersonResource objectForKey:@"name"], linkedPeople9[@"name"], @"Linked person's 9 name is not equal to %@", linkedPeople11[[[@"name"]]]);
    XCTAssertEqualObjects([linkedPersonResource objectForKey:@"name"], linkedPeople9[@"name"], @"Linked person's 9 name is not equal to %@", linkedPeople11[[[@"name"]]]);

    
}

- (void)testResourceModels {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linkedAuthor11 = @{ @"id" : @11, @"name" : @"Bandit" };
    NSArray *linkedAuthors = @[ linkedAuthor9, linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    PostResource *postResource = [jsonAPI resourceForKey:@"posts"];
    
    XCTAssert([postResource class] == [PostResource class], @"Post resource is not of type PostResource, but %@", [postResource class]);
    XCTAssert([postResource.author class] == [PeopleResource class], @"Post resource's author is not of type PeopleResource, but %@", [postResource.author class]);
    XCTAssertEqualObjects(postResource.name, post[@"name"], @"Post name is not equal to %@", post[[[@"name"]]]);
    XCTAssertEqualObjects(postResource.author.name, linkedAuthor9[@"name"], @"Author name is not equal to %@", post[[[@"name"]]]);
}

- (void)testLinksInLinked {
    NSDictionary *meta = @{};
    NSDictionary *linkedBook9 = @{ @"id" : @9, @"name" : @"A Book That's A Book", @"links" : @{ @"author" : @11 } };
    NSArray *linkedBooks = @[ linkedBook9 ];
    NSDictionary *linkedAuthor11 = @{ @"id" : @11, @"name" : @"Bandit"};
    NSArray *linkedAuthors = @[ linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors, @"books" : linkedBooks};
    NSDictionary *chapter = @{ @"id" : @1, @"name" : @"Chapter 1: And It Begins", @"links" : @{ @"book" : @9 } };
    NSArray *chapters = @[ chapter ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"chapters" : chapters };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    
    JSONAPIResource *chapterResource = [jsonAPI resourceForKey:@"chapters"];
    JSONAPIResource *bookResource = [chapterResource linkedResourceForKey:@"book"];
    JSONAPIResource *authorResource = [bookResource linkedResourceForKey:@"author"];
    
    XCTAssertEqualObjects([chapterResource objectForKey:@"name"], chapter[@"name"], @"Chapter name should equal %@", chapter[[[@"name"]]]);
    XCTAssertEqualObjects([bookResource objectForKey:@"name"], linkedBook9[@"name"], @"Book name should equal %@", chapter[[[@"name"]]]);
    XCTAssertEqualObjects([authorResource objectForKey:@"name"], linkedAuthor11[@"name"], @"Author name should equal %@", chapter[[[@"name"]]]);
}

- (void)testMapKeysToProperties {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linkedAuthor11 = @{ @"id" : @11, @"name" : @"Bandit" };
    NSArray *linkedAuthors = @[ linkedAuthor9, linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    PostResource *postResource = [jsonAPI resourceForKey:@"posts"];
    
    XCTAssert([postResource class] == [PostResource class], @"Post resource is not of type PostResource, but %@", [postResource class]);
    XCTAssert([postResource.author class] == [PeopleResource class], @"Post resource's author is not of type PeopleResource, but %@", [postResource.author class]);
    XCTAssertEqualObjects(postResource.name, post[@"name"], @"Post name is not equal to %@", post[[[@"name"]]]);
    XCTAssertEqualObjects(postResource.author.name, linkedAuthor9[@"name"], @"Author name is not equal to %@", post[[[@"name"]]]);
}

- (void)testCopying {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linkedAuthor11 = @{ @"id" : @11, @"name" : @"Bandit" };
    NSArray *linkedAuthors = @[ linkedAuthor9, linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    PostResource *postResource = [jsonAPI resourceForKey:@"posts"];
    
    PostResource *copyPostResource = [postResource copy];
    
    XCTAssertNotEqual(copyPostResource, postResource, @"Copy post is equal to original");
    XCTAssertNotNil(copyPostResource.name, @"Copy post name is nil");
    XCTAssertEqualObjects(copyPostResource.name, postResource.name, @"Copy post name is not equal to %@", postResource.name);
    XCTAssertNotNil(copyPostResource.author, @"Copy post author is nil");
    XCTAssertNotNil(copyPostResource.author.name, @"Copy post author name is nil");
    XCTAssertEqualObjects(copyPostResource.author.name, postResource.author.name, @"Copy post author name is not equal to %@", postResource.author.name);
}

- (void)testFormatBlock {
    [[JSONAPIResourceFormatter defaultInstance] registerFormat:@"Date" withBlock:^id(id jsonValue) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        NSDate *date = nil;
        NSError *error = nil;
        if (![dateFormatter getObjectValue:&date forString:jsonValue range:nil error:&error]) {
            NSLog(@"Date '%@' could not be parsed: %@", jsonValue, error);
        }
        
        return date;
    }];
    
    BOOL hasFormatBlock = [[JSONAPIResourceFormatter defaultInstance] hasFormatBlock:@"Date"];
    XCTAssert(hasFormatBlock, @"Format block for Date is not defined");
    
    // Create date for testing
    NSString *dateToTestWith = @"2013-10-14T05:34:32+600";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *date = nil;
    NSError *error = nil;
    if (![dateFormatter getObjectValue:&date forString:dateToTestWith range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateToTestWith, error);
    }
    
    // Create json
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linkedAuthor11 = @{ @"id" : @11, @"name" : @"Bandit" };
    NSArray *linkedAuthors = @[ linkedAuthor9, linkedAuthor11 ];
    NSDictionary *linked = @{ @"authors" : linkedAuthors };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"date" : dateToTestWith, @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    PostResource *postResource = [jsonAPI resourceForKey:@"posts"];
    
    PostResource *copyPostResource = [postResource copy];
    
    XCTAssertNotEqual(postResource, copyPostResource, @"Post is not equal to copy");
    XCTAssertNotNil(postResource.date, @"Post date is not nil");
    XCTAssertEqualObjects(postResource.date, date, @"Post date is not equal to %@", date);
}

@end

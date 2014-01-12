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

    [JSONAPIResourceLinker link:@"author" toLinkedType:@"authors"];
    [JSONAPIResourceLinker link:@"authors" toLinkedType:@"authors"]; // Don't NEED this but why not be explicit
    [JSONAPIResourceLinker link:@"person" toLinkedType:@"people"];
    
    [JSONAPIResourceModeler useResource:[CommentResource class] toLinkedType:@"comment"];
    [JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"authors"];
    [JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"people"];
    [JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];
    
}

- (void)tearDown
{
    [JSONAPIResourceLinker unlinkAll];
    [JSONAPIResourceModeler unmodelAll];
    
    [super tearDown];
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
    XCTAssert(linked.count == jsonAPI.linked.count, @"Linked count does not equal %d", linked.count);
    
}

- (void)testLinkedResource {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linked = @{ @"authors" : @[ linkedAuthor9 ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *linkedAuthorResource = [[jsonAPI.linked objectForKey:@"authors"] objectForKey:@9];
    XCTAssertEqualObjects([linkedAuthor9 objectForKey:@"id"], linkedAuthorResource.ID , @"Author resource ID does not equal %@", [linkedAuthor9 objectForKey:@"id"]);
    XCTAssertEqualObjects([linkedAuthor9 objectForKey:@"name"], [linkedAuthorResource objectForKey:@"name"] , @"Author resource name does not equal %@", [linkedAuthor9 objectForKey:@"name"]);
}

- (void)testBadLinked
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSArray *linked = @[ @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] } ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSLog(@"%d HRM %d", jsonAPI.linked.count, 0);
    XCTAssert(jsonAPI.linked.count == 0, @"Linked is not 0");
    
}

- (void)testResourcesCount {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    XCTAssert(posts.count == [jsonAPI resourcesForKey:@"posts"].count, @"Posts count does not equal %d", posts.count);
}

- (void)testResourcesObject {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];

    XCTAssertEqualObjects([post objectForKey:@"id"], resource.ID, @"Posts ID does not equal %@", [post objectForKey:@"id"]);
    XCTAssertEqualObjects([post objectForKey:@"name"], [resource objectForKey:@"name"], @"Posts name does not equal %@", [post objectForKey:@"name"]);
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
    
    JSONAPIResource *linkedAuthor = [resource linkedResourceForKey:@"author"];
    
    XCTAssertNotNil(linkedAuthor, @"Linked author is nil");
    XCTAssertEqualObjects([linkedAuthor objectForKey:@"name"], [linkedAuthor9 objectForKey:@"name"], @"Linked author's name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    XCTAssertEqualObjects([linkedAuthor objectForKey:@"name"], [linkedAuthor9 objectForKey:@"name"], @"Linked author's name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    
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
        if ([linkedAuthorResource.ID isEqualToNumber:[linkedAuthor9 objectForKey:@"id"]] == YES) {
            linkedAuthorResource9 = linkedAuthorResource;
        } else if ([linkedAuthorResource.ID isEqualToNumber:[linkedAuthor11 objectForKey:@"id"]] == YES) {
            linkedAuthorResource11 = linkedAuthorResource;
        }
    }
    
    XCTAssert(linkedAuthorsResources.count == linkedAuthors.count, @"Linked author resource count is not %d", linkedAuthors.count);
    
    XCTAssertEqualObjects([linkedAuthorResource9 objectForKey:@"name"], [linkedAuthor9 objectForKey:@"name"], @"Linked author's 9 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    XCTAssertEqualObjects([linkedAuthorResource9 objectForKey:@"name"], [linkedAuthor9 objectForKey:@"name"], @"Linked author's 9 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    
    XCTAssertEqualObjects([linkedAuthorResource11 objectForKey:@"name"], [linkedAuthor11 objectForKey:@"name"], @"Linked author's 11 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    XCTAssertEqualObjects([linkedAuthorResource11 objectForKey:@"name"], [linkedAuthor11 objectForKey:@"name"], @"Linked author's 11 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    
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
    XCTAssertEqualObjects([linkedPersonResource objectForKey:@"name"], [linkedPeople9 objectForKey:@"name"], @"Linked person's 9 name is not equal to %@", [linkedPeople11 objectForKey:@"name"]);
    XCTAssertEqualObjects([linkedPersonResource objectForKey:@"name"], [linkedPeople9 objectForKey:@"name"], @"Linked person's 9 name is not equal to %@", [linkedPeople11 objectForKey:@"name"]);

    
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
    
    XCTAssertEqual([postResource class], [PostResource class], @"Post resource is not of type PostResource, but %@", [postResource class]);
    XCTAssertEqual([postResource.author class], [PeopleResource class], @"Post resource's author is not of type PeopleResource, but %@", [postResource.author class]);
    XCTAssertEqualObjects(postResource.name, [post objectForKey:@"name"], @"Post name is not equal to %@", [post objectForKey:@"name"]);
    XCTAssertEqualObjects(postResource.author.name, [linkedAuthor9 objectForKey:@"name"], @"Author name is not equal to %@", [post objectForKey:@"name"]);
}

@end

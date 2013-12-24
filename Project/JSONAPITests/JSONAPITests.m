//
//  JSONAPITests.m
//  JSONAPITests
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONAPI.h"

@interface JSONAPITests : XCTestCase

@end

@implementation JSONAPITests

- (void)setUp
{
    [super setUp];

    [JSONAPIResourceLinker link:@"author" toLinked:@"authors"];
    [JSONAPIResourceLinker link:@"authors" toLinked:@"authors"]; // Don't NEED this but why not be explicit
    [JSONAPIResourceLinker link:@"person" toLinked:@"people"];
    
}

- (void)tearDown
{
    [JSONAPIResourceLinker unlinkAll];
    
    [super tearDown];
}

- (void)testMeta
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSAssert([meta isEqualToDictionary:jsonAPI.meta], @"Meta does not equal %@", meta);
    //    @"No implementation for \"%s\"", __PRETTY_FUNCTION__
    
}

- (void)testBadMeta
{
    NSArray *meta = @[ @{ @"page_number" : @1, @"number_of_pages" : @5} ];
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSAssert(jsonAPI.meta == nil, @"Meta is not nil");
    
}

- (void)testLinkedCount
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSAssert(linked.count == jsonAPI.linked.count, @"Linked count does not equal %d", linked.count);
    
}

- (void)testLinkedResource {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linkedAuthor9 = @{ @"id" : @9, @"name" : @"Josh" };
    NSDictionary *linked = @{ @"authors" : @[ linkedAuthor9 ] };
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *linkedAuthorResource = [[jsonAPI.linked objectForKey:@"authors"] objectForKey:@9];
    NSAssert([[linkedAuthor9 objectForKey:@"id"] isEqualToNumber:linkedAuthorResource.ID] , @"Author resource ID does not equal %@", [linkedAuthor9 objectForKey:@"id"]);
    NSAssert([[linkedAuthor9 objectForKey:@"name"] isEqualToString:[linkedAuthorResource objectForKey:@"name"]] , @"Author resource name does not equal %@", [linkedAuthor9 objectForKey:@"name"]);
}

- (void)testBadLinked
{
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSArray *linked = @[ @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] } ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : @[ @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } } ] };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSAssert(jsonAPI.linked.count == 0, @"Linked is not 0");
    
}

- (void)testResourcesCount {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    NSAssert(posts.count == [jsonAPI resourcesForKey:@"posts"].count, @"Posts count does not equal %d", posts.count);
}

- (void)testResourcesObject {
    
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"authors" : @[ @{ @"id" : @9, @"name" : @"Josh" } ] };
    NSDictionary *post = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9 } };
    NSArray *posts = @[ post ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    JSONAPI *jsonAPI = [[JSONAPI alloc] initWithDictionary:json];
    JSONAPIResource *resource = [jsonAPI resourceForKey:@"posts"];

    NSAssert([[post objectForKey:@"id"] isEqualToNumber:resource.ID] , @"Posts ID does not equal %@", [post objectForKey:@"id"]);
    NSAssert([[post objectForKey:@"name"] isEqualToString:[resource objectForKey:@"name"]] , @"Posts name does not equal %@", [post objectForKey:@"name"]);
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
    
    NSAssert(linkedAuthor != nil, @"Linked author is nil");
    NSAssert([[linkedAuthor objectForKey:@"name"] isEqualToString:[linkedAuthor9 objectForKey:@"name"]], @"Linked author's name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    NSAssert([[linkedAuthor objectForKey:@"name"] isEqualToString:[linkedAuthor9 objectForKey:@"name"]], @"Linked author's name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    
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
    
    NSAssert(linkedAuthorsResources.count == linkedAuthors.count, @"Linked author resource count is not %d", linkedAuthors.count);
    
    NSAssert([[linkedAuthorResource9 objectForKey:@"name"] isEqualToString:[linkedAuthor9 objectForKey:@"name"]], @"Linked author's 9 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    NSAssert([[linkedAuthorResource9 objectForKey:@"name"] isEqualToString:[linkedAuthor9 objectForKey:@"name"]], @"Linked author's 9 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    
    NSAssert([[linkedAuthorResource11 objectForKey:@"name"] isEqualToString:[linkedAuthor11 objectForKey:@"name"]], @"Linked author's 11 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    NSAssert([[linkedAuthorResource11 objectForKey:@"name"] isEqualToString:[linkedAuthor11 objectForKey:@"name"]], @"Linked author's 11 name is not equal to %@", [linkedAuthor9 objectForKey:@"name"]);
    
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
    
    NSAssert(linkedPersonResource != nil, @"Linked person is nil");
    NSAssert([[linkedPersonResource objectForKey:@"name"] isEqualToString:[linkedPeople9 objectForKey:@"name"]], @"Linked person's 9 name is not equal to %@", [linkedPeople11 objectForKey:@"name"]);
    NSAssert([[linkedPersonResource objectForKey:@"name"] isEqualToString:[linkedPeople9 objectForKey:@"name"]], @"Linked person's 9 name is not equal to %@", [linkedPeople11 objectForKey:@"name"]);

    
}

@end

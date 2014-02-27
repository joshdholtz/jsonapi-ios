# JSONAPI - iOS

[![Build Status](https://travis-ci.org/joshdholtz/jsonapi-ios.png?branch=master)](https://travis-ci.org/joshdholtz/jsonapi-ios)

A library for loading data from a [JSON API](http://jsonapi.org) datasource. Parses JSON API data into models with support for auto-linking of resources and custom model classes.

### Updates

Version | Changes
--- | ---
**0.1.2** | `JSONAPIResource` IDs can either be numbers or strings (thanks [danylhebreux](https://github.com/danylhebreux)); `JSONAPIResource` subclass can have mappings defined to set JSON values into properties automatically - [more info](#resource-mappings)
**0.1.1** | Fixed linked resources with links so they actually link to other linked resources
**0.1.0** | Initial release

### Features
- Parses datasource into manageable objects of `JSONAPIResource`
- Auto-links resources with custom link mapping definitions using `JSONAPIResourceLinker` (ex: link 'book' to 'books', link 'person' to 'people')
- Allows resource types to be created into subclasses of `JSONAPIResource` using `JSONAPIResourceModeler`
- Set mapping for `JSONAPIResource` subclass to set JSON values into properties

## Installation

### Drop-in Classes
Clone the repository and drop in the .h and .m files from the "Classes" directory into your project.

### CocoaPods

JSONAPI is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'JSONAPI', '~> 0.1.1'

## Usage

### JSONAPI
`JSONAPI` parses and validates a JSON API document into a usable object. This object holds the response as an NSDictionary but provides methods to accomdate the JSON API format such as `meta`, `linked`, and `(NSArray*)resourcesForKey:(NSString*)key`.

### JSONAPIResource
`JSONAPIResource` is an object that holds data for each resource in a JSON API document. This objects holds the "id", "href", and "links" as properties but also the rest of the object as an NSDictionary that can be accessed through `(id)objectForKey:(NSString*)key`. There is also a method for retrieving linked resources from the JSON API document by using `(id)linkedResourceForKey:(NSString*)key`.

#### Resource mappings
`(NSDictionary*)mapKeysToProperties` can be overwritten to define a dictionary mapping of JSON keys to map into properties of a subclassed JSONAPIResource. Use a "links." prefix on the JSON key to map a linked JSONAPIResource model or array of JSONAPIResource models

````objc

@implementation ASubclassedResource

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'first_name' to 'firstName' property
    // Maps linked resource in JSON key 'author' to 'author' property
    // Maps linked resource in JSON key 'comments' to 'comments' property
    return @{
             @"first_name" : @"firstName",
             @"links.author" : @"author",
             @"links.comments" : @"comments"
             };

@end

````

### JSONAPIResourceLinker
`JSONAPIResourceLinker` is used for configuring the type of 'links' resources to 'linked' resources.

#### Example
The "author" defined in "links" need to be mapped to the "people" type in "linked"

````
{
    "posts":[
        {
            "id":1,
            "name":"A post!",
            "links":{
                "author":9
            }
        }
    ],
    "linked":{
        "people":[
            {
                "id":9,
                "name":"Josh Holtz"
            }
        ]
    }
}

````

### JSONAPIResourceModeler

`JSONAPIResourceModeler` is used for configuring what type of JSONAPIResource subclass that resource types are created into.

## Examples

### Parsing - Basic

```` objc

NSString *json = @"{\"posts\":[{\"id\":1,\"name\":\"A post!\"},{\"id\":2,\"name\":\"Another post!\"}]}";

// Parses JSON string into JSONAPI object
JSONAPI *jsonApi = [JSONAPI JSONAPIWithString:json];

// Iterates over JSONAPIResources for "posts"
NSArray *posts = [jsonApi resourcesForKey:@"posts"];
for (JSONAPIResource *post in posts) {
    // Prints post name
    NSLog(@"\"%@\"", [post objectForKey:@"name"]);
}


````

### Parsing - Using linked resources

```` objc

NSString *json = @"{\"posts\":[{\"id\":1,\"name\":\"A post!\",\"links\":{\"author\":9}},{\"id\":2,\"name\":\"Another post!\",\"links\":{\"author\":10}}],\"linked\":{\"people\":[{\"id\":9,\"name\":\"Josh Holtz\"},{\"id\":10,\"name\":\"Bandit the Cat\"}]}}";

// Links "author" resource to "people" linked resources
[JSONAPIResourceLinker link:@"author" toLinkedType:@"people"];

// Parses JSON string into JSONAPI object
JSONAPI *jsonApi = [JSONAPI JSONAPIWithString:json];

// Iterates over JSONAPIResources for "posts"
NSArray *posts = [jsonApi resourcesForKey:@"posts"];
for (JSONAPIResource *post in posts) {
    // Gets linked author resource
    JSONAPIResource *author = [post linkedResourceForKey:@"author"];
    
    // Prints post name and author
    NSLog(@"\"%@\" by %@", [post objectForKey:@"name"], [author objectForKey:@"name"]);
}

````

### Parsing - Using linked resources and subclassed JSONAPIResource classes

```` objc

NSString *json = @"{\"posts\":[{\"id\":1,\"name\":\"A post!\",\"links\":{\"author\":9}},{\"id\":2,\"name\":\"Another post!\",\"links\":{\"author\":10}}],\"linked\":{\"people\":[{\"id\":9,\"name\":\"Josh Holtz\"},{\"id\":10,\"name\":\"Bandit the Cat\"}]}}";

// Links "author" resource to "people" linked resources
[JSONAPIResourceLinker link:@"author" toLinkedType:@"people"];

//
[JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"people"];
[JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];

// Parses JSON string into JSONAPI object
JSONAPI *jsonApi = [JSONAPI JSONAPIWithString:json];

// Gets posts from JSONAPI that will be an array of PostResource objects
NSArray *posts = [jsonApi resourcesForKey:@"posts"];

// Parsing using JSONAPI and modeled resources (PostResource, PeopleResource, CommentResource
for (PostResource *post in posts) {
    
    PeopleResource *author = post.author;
    NSLog(@"\"%@\" by %@", post.name, author.name);
}

````

#### PostResource.h, PostResource.m

```` objc

@interface PostResource : JSONAPIResource

- (PeopleResource*)author;
- (NSString*)name;

@end

@implementation PostResource

- (PeopleResource *)author {
    return [self linkedResourceForKey:@"author"];
}

- (NSArray *)comments {
    return [self linkedResourceForKey:@"comments"];
}

- (NSString *)name {
    return [self objectForKey:@"name"];
}

@end

````

#### PeopleResource.h, PeopleResource.m

```` objc

@interface PeopleResource : JSONAPIResource

- (NSString*)name;

@end

@implementation PeopleResource

- (NSString *)name {
    return [self objectForKey:@"name"];
}

@end

````

### Parsing - Using linked resources, subclassed JSONAPIResource classes, and model mappings
This example shows how a response can be mapped directly into properties of a sublcasses JSONAPIResource

```` objc

NSString *json = @"{\"posts\":[{\"id\":1,\"name\":\"A post!\",\"links\":{\"author\":9,\"comments\":[2,3]}},{\"id\":2,\"name\":\"Another post!\",\"links\":{\"author\":10,\"comments\":[3,4]}}],\"linked\":{\"people\":[{\"id\":9,\"name\":\"Josh Holtz\"},{\"id\":10,\"name\":\"Bandit the Cat\"}],\"comments\":[{\"id\":2,\"text\":\"Omg this post is awesome\"},{ \"id\":3,\"text\":\"Omg this post is awesomer\"},{ \"id\":4,\"text\":\"Meeeehhhhh\"}]}}";

// Links "author" resource to "people" linked resources
[JSONAPIResourceLinker link:@"author" toLinkedType:@"people"];

//
[JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"people"];
[JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];
[JSONAPIResourceModeler useResource:[CommentResource class] toLinkedType:@"comments"];

// Parses JSON string into JSONAPI object
JSONAPI *jsonApi = [JSONAPI JSONAPIWithString:json];

// Gets posts from JSONAPI that will be an array of PostResource objects
NSArray *posts = [jsonApi resourcesForKey:@"posts"];

// Parsing using JSONAPI and modeled resources (PostResource, PeopleResource, CommentResource
for (PostResource *post in posts) {
    
    PeopleResource *author = post.author;
    NSLog(@"\"%@\" by %@", post.name, author.name);
    
    NSArray *comments = post.comments;
    for (CommentResource *comment in comments) {
        NSLog(@"\t%@", comment.text);
    }
}

````

#### PostResource.h, PostResource.m

```` objc

@interface PostResource : JSONAPIResource

- (PeopleResource*)author;
- (NSArray*)comments; // Array of CommentResource
- (NSString*)name;

@end

@implementation PostResource

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps linked resource in JSON key 'author' to 'author' property
    // Maps linked resource in JSON key 'comments' to 'comments' property
    return @{
             @"name" : @"name",
             @"links.author" : @"author",
             @"links.comments" : @"comments"
             };

@end

````

#### PeopleResource.h, PeopleResource.m

```` objc

@interface PeopleResource : JSONAPIResource

- (NSString*)name;

@end

@implementation PeopleResource

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    return @{
             @"name" : @"name"
             };

@end

````

#### CommentResource.h, CommentResource.m

```` objc

@interface CommentResource : JSONAPIResource

- (NSString*)text;

@end

@implementation CommentResource

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'text' to 'text' property
    return @{
             @"text" : @"text"
             };

@end

````

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

JSONAPI is available under the MIT license. See the LICENSE file for more info.



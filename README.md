# JSONAPI - iOS

[![Build Status](https://travis-ci.org/joshdholtz/jsonapi-ios.png?branch=master)](https://travis-ci.org/joshdholtz/jsonapi-ios)
![](https://cocoapod-badges.herokuapp.com/v/JSONAPI/badge.png)

A library for loading data from a [JSON API](http://jsonapi.org) datasource. Parses JSON API data into models with support for auto-linking of resources and custom model classes.

### Updates

Version | Changes
--- | ---
**1.0.0-rc1** | Rewrote core of `JSONAPI` and `JSONAPIResource` and all unit tests to be up to spec with JSON API spec 1.0.0-rc3. Removed `JSONAPIResourceLinker`. Added `JSONAPIErrorResource`
**0.2.0** | Added `NSCopying` and `NSCoded` to `JSONAPIResource`; Added `JSONAPIResourceFormatter` to format values before getting mapped - [more info](#formatter)
**0.1.2** | `JSONAPIResource` IDs can either be numbers or strings (thanks [danylhebreux](https://github.com/danylhebreux)); `JSONAPIResource` subclass can have mappings defined to set JSON values into properties automatically - [more info](#resource-mappings)
**0.1.1** | Fixed linked resources with links so they actually link to other linked resources
**0.1.0** | Initial release

### Features
- Parses datasource into manageable objects of `JSONAPIResource`
- Allows resource types to be created into subclasses of `JSONAPIResource` using `JSONAPIResourceModeler`
- Set mapping for `JSONAPIResource` subclass to set JSON values into properties

## Installation

### Drop-in Classes
Clone the repository and drop in the .h and .m files from the "Classes" directory into your project.

### CocoaPods

JSONAPI is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'JSONAPI', '~> 1.0.0-rc1'

## Usage

### JSONAPI
`JSONAPI` parses and validates a JSON API document into a usable object. This object holds the response as an NSDictionary but provides methods to accommodate the JSON API format such as `meta`, `linked`, and `(NSArray*)resourcesForKey:(NSString*)key`.

### JSONAPIResource
`JSONAPIResource` is an object that holds data for each resource in a JSON API document. This objects holds the "id", "href", and "links" as properties but also the rest of the object as an NSDictionary that can be accessed through `(id)objectForKey:(NSString*)key`. There is also a method for retrieving linked resources from the JSON API document by using `(id)linkedResourceForKey:(NSString*)key`.

#### Resource mappings
`(NSDictionary*)mapKeysToProperties` can be overwritten to define a dictionary mapping of JSON keys to map into properties of a subclassed JSONAPIResource. Use a "links." prefix on the JSON key to map a linked JSONAPIResource model or array of JSONAPIResource models

#### Formatter
`JSONAPIResourceFormatter` is used to format values before getting mapped from `mapKeysToProperties`.

Below is an example to register a "Date" function to format a date in a NSString object to an NSDate object before its mapped to the JSONAPIResource instance.

````objc

[JSONAPIResourceFormatter registerFormat:@"Date" withBlock:^id(id jsonValue) {
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

````

##### Usage

````objc

@interface ASubclassedResource

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *authors;
@property (nonatomic, strong) NSArray *comments;

@end

@implementation ASubclassedResource

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'first_name' to 'firstName' property
    // Maps values in JSON key 'date' to 'date' property using the 'Date' formatter
    // Maps linked resource in JSON key 'author' to 'author' property
    // Maps linked resource in JSON key 'comments' to 'comments' property
    return @{
             @"first_name" : @"firstName",
             @"date" : @"Date:date",
             @"links.author" : @"author",
             @"links.comments" : @"comments"
             };

@end

````

### JSONAPIResourceModeler

`JSONAPIResourceModeler` is used for configuring what type of JSONAPIResource subclass that resource types are created into.

## Examples

### Parsing - Basic

```` objc

NSString *json = @"{\"data\":[{\"id\":1,\"type\":\"posts\",\"name\":\"A post!\"},{\"id\":2,\"type\":\"posts\",\"name\":\"Another post!\"}]}";

// Parses JSON string into JSONAPI object
JSONAPI *jsonApi = [JSONAPI JSONAPIWithString:json];

// Iterates over JSONAPIResources for "posts"
NSArray *posts = jsonApi.resources;
for (JSONAPIResource *post in posts) {
    // Prints post name
    NSLog(@"\"%@\"", [post objectForKey:@"name"]);
}


````

### Parsing - Using  subclassed JSONAPIResource classes, and model mappings
This example shows how a response can be mapped directly into properties of a sublcasses JSONAPIResource

```` objc

NSString *json = @"{ \"data\": [{ \"type\": \"posts\", \"id\": \"1\", \"title\": \"JSON API paints my bikeshed!\", \"links\": { \"self\": \"http:\/\/example.com\/posts\/1\", \"author\": { \"linkage\": { \"type\": \"people\", \"id\": \"9\" } }, \"comments\": { \"linkage\": [ { \"type\": \"comments\", \"id\": \"5\" }, { \"type\": \"comments\", \"id\": \"12\" } ] } } }], \"included\": [{ \"type\": \"people\", \"id\": \"9\", \"first-name\": \"Dan\", \"last-name\": \"Gebhardt\", \"twitter\": \"dgeb\", \"links\": { } }, { \"type\": \"comments\", \"id\": \"5\", \"body\": \"First!\", \"links\": { \"author\": { \"linkage\": { \"type\": \"people\", \"id\": \"9\" } } } }, { \"type\": \"comments\", \"id\": \"12\", \"body\": \"I like XML better\", \"links\": { \"author\": { \"linkage\": { \"type\": \"people\", \"id\": \"9\" } } } }] }";

// Loads "people" into `PeopleResource`, "posts" into `PostResource`, and "comments" into `CommentResource`
[JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"people"];
[JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];
[JSONAPIResourceModeler useResource:[CommentResource class] toLinkedType:@"comments"];

// Parses JSON string into JSONAPI object
JSONAPI *jsonApi = [JSONAPI JSONAPIWithString:json];

// Gets posts from JSONAPI that will be an array of PostResource objects
NSArray *posts = jsonApi.resources;

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

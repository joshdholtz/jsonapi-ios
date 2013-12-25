# JSONAPI - iOS

A parser for [JSON API](http://jsonapi.org) documents.

## Installation

### Drop-in Classes
Clone the repository and drop in the .h and .m files in the "Classes" directory.

### CocoaPods

JSONAPI is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "JSONAPI"

## Usage

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

## Author

Josh Holtz, me@joshholtz.com
@joshdholtz

## License

JSONAPI is available under the MIT license. See the LICENSE file for more info.


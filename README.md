# JSONAPI - iOS

[![Build Status](https://travis-ci.org/joshdholtz/jsonapi-ios.png?branch=master)](https://travis-ci.org/joshdholtz/jsonapi-ios)
![](https://cocoapod-badges.herokuapp.com/v/JSONAPI/badge.png)
[![Join the chat at https://gitter.im/joshdholtz/jsonapi-ios](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/joshdholtz/jsonapi-ios?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A library for loading data from a [JSON API](http://jsonapi.org) datasource. Parses JSON API data into models with support for linking of properties and other resources.

### Quick Usage
```objc
NSDictionary *json = [self responseFromAPIRequest];
JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];

ArticleResource *article = jsonAPI.resource;
NSLog(@"Title: %@", article.title);
```

For some full examples on how to use everything, please see the tests - https://github.com/joshdholtz/jsonapi-ios/blob/master/Project/JSONAPITests/JSONAPITests.m

### Updates

Version | Changes
--- | ---
**1.0.6** | Improved resource parsing and added parsing of `selfLinks` (https://github.com/joshdholtz/jsonapi-ios/pull/35). Thanks to [ artcom](https://github.com/ artcom) for helping! Also removed the need to define `setIdProperty` and `setSelfLinkProperty` in every resource (automatically mapped in the init of `JSONAPIResourceDescriptor`)
**1.0.5** | Fix 1-to-many relationships serialization according to JSON API v1.0 (https://github.com/joshdholtz/jsonapi-ios/pull/34). Thanks to [RafaelKayumov](https://github.com/RafaelKayumov) for helping!
**1.0.4** | Add support for empty to-one relationship according to JSON API v1.0 (https://github.com/joshdholtz/jsonapi-ios/pull/33). Thanks to [RafaelKayumov](https://github.com/RafaelKayumov) for helping!
**1.0.3** | Add ability to map different types of objects (https://github.com/joshdholtz/jsonapi-ios/pull/32). Thanks to [ealeksandrov](https://github.com/ealeksandrov) for helping!
**1.0.2** | Just some bug fixes. Thanks to [christianklotz](https://github.com/christianklotz) for helping again!
**1.0.1** | Now safely checks for `NSNull` in the parsed JSON. Thanks to [christianklotz](https://github.com/christianklotz) for that fix!
**1.0.0** | We did it team! We are at the `JSON API 1.0 final` spec. Resources now use `JSONAPIResourceDescriptor` for more explicit definitions. **HUGE** thanks to [jkarmstr](https://github.com/jkarmstr) for doing all the dirty work. Also thanks to [edopelawi ](https://github.com/edopelawi ), [BenjaminDigeon](https://github.com/BenjaminDigeon), and [christianklotz](https://github.com/christianklotz) for some bug fixes!
**1.0.0-rc1** | Rewrote core of `JSONAPI` and `JSONAPIResource` and all unit tests to be up to spec with JSON API spec 1.0.0-rc3. Removed `JSONAPIResourceLinker`. Added `JSONAPIErrorResource`
**0.2.0** | Added `NSCopying` and `NSCoded` to `JSONAPIResource`; Added `JSONAPIResourceFormatter` to format values before getting mapped - [more info](#formatter)
**0.1.2** | `JSONAPIResource` IDs can either be numbers or strings (thanks [danylhebreux](https://github.com/danylhebreux)); `JSONAPIResource` subclass can have mappings defined to set JSON values into properties automatically - [more info](#resource-mappings)
**0.1.1** | Fixed linked resources with links so they actually link to other linked resources
**0.1.0** | Initial release

### Features
- Allows resource types to be created into subclasses of `JSONAPIResource`
- Set mapping for `JSONAPIResource` subclass to set JSON values and relationships into properties

## Installation

### Drop-in Classes
Clone the repository and drop in the .h and .m files from the "Classes" directory into your project.

### CocoaPods

JSONAPI is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'JSONAPI', '~> 1.0.6'

## Classes/protocols
For some full examples on how to use everything, please see the tests - https://github.com/joshdholtz/jsonapi-ios/blob/master/Project/JSONAPITests/JSONAPITests.m

### JSONAPI
`JSONAPI` parses and validates a JSON API document into a usable object. This object holds the response as an NSDictionary but provides methods to accomdate the JSON API format such as `meta`, `errors`, `linked`, `resources`, and `includedResources`.

### JSONAPIResource
Protocol of an object that is available for JSON API serialization. When developing model classes for use with JSON-API, it is suggested that classes be derived from `JSONAPIResourceBase`, but that is not required. An existing model class can be adapted for JSON-API by implementing this protocol.

### JSONAPIResourceBase
`JSONAPIResourceBase` is an object (that gets subclassed) that holds data for each resource in a JSON API document. This objects holds the "id" as `ID` and link for self as `selfLink` as well as attributes and relationships defined by descriptors (see below)

### JSONAPIResourceDescriptor
`+ (JSONAPIResourceDescriptor*)descriptor` should be overwritten to define descriptors for mapping of JSON keys and relationships into properties of a subclassed JSONAPIResource.

## Full Example

### ViewController.m

```objc
NSDictionary *json = [self responseFromAPIRequest];
JSONAPI *jsonAPI = [JSONAPI jsonAPIWithDictionary:json];

ArticleResource *article = jsonAPI.resource;
NSLog(@"Title: %@", article.title);
NSLog(@"Author: %@ %@", article.author.firstName, article.author.lastName);
NSLog(@"Comment Count: %ld", article.comments.count);
```

### ArticleResource.h

```objc

@interface ArticleResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) PeopleResource *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *comments;

@end
```

### ArticleResource.m

```objc
@implementation ArticleResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"articles"];

        [__descriptor addProperty:@"title"];
        [__descriptor addProperty:@"date"
                 withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"date" withFormat:[NSDateFormatter RFC3339DateFormatter]]];

        [__descriptor hasOne:[PeopleResource class] withName:@"author"];
        [__descriptor hasMany:[CommentResource class] withName:@"comments"];
    });

    return __descriptor;
}

@end

```

### PeopleResource.h

```objc
@interface PeopleResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *twitter;

@end
```

### PeopleResource.m

```objc
@implementation PeopleResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"people"];

        [__descriptor addProperty:@"firstName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"first-name"]];
        [__descriptor addProperty:@"lastName" withJsonName:@"last-name"];
        [__descriptor addProperty:@"twitter"];
    });

    return __descriptor;
}

@end
```

### CommentResource.h

```objc
@interface CommentResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) PeopleResource *author;

@end
```

### CommentResource.m

```objc
@implementation CommentResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"comments"];

        [__descriptor addProperty:@"text" withJsonName:@"body"];

        [__descriptor hasOne:[PeopleResource class] withName:@"author"];
    });

    return __descriptor;
}

@end
```

## Advanced

### How to do custom "sub-resources" mappings
Sometimes you may have parts of a resource that need to get mapped to something more specific than just an `NSDictionary`. Below is an example on how to map an `NSDictionary` to non-JSONAPIResource models.

We are essentially creating a property descriptor that maps to a private property on the resource. We then override that properties setter and do our custom mapping there.

#### Resource part of JSON API Response
```js
"attributes":{
  "title": "Something something blah blah blah"
  "image": {
    "large": "http://someimageurl.com/large",
    "medium": "http://someimageurl.com/medium",
    "small": "http://someimageurl.com/small"
  }
}
```

#### ArticleResource.h

```objc

@interface ArticleResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *title;

// The properties we are pulling out of a a "images" dictionary
@property (nonatomic, storng) NSString *largeImageUrl;
@property (nonatomic, storng) NSString *mediumImageUrl;
@property (nonatomic, storng) NSString *smallImageUrl;

@end
```

#### ArticleResource.m

```objc
@interface ArticleResource()

// Private variable used to store raw NSDictionary
// We will override the setter and set our custom properties there
@property (nonatomic, strong) NSDictionary *rawImage;

@end

@implementation ArticleResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"articles"];

        [__descriptor addProperty:@"title"];
        [__descriptor addProperty:@"rawImage" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"image"]];

    });

    return __descriptor;
}

- (void)setRawImage:(NSDictionary*)rawImage {
  _rawImage = rawImage;

  // Pulling the large, medium, and small urls out when
  // this property gets set by the JSON API parser
  _largeImageUrl = _rawImage[@"large"];
  _mediumImageUrl = _rawImage[@"medium"];
  _smallImageUrl = _rawImage[@"small"];
}

@end

```

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

JSONAPI is available under the MIT license. See the LICENSE file for more info.

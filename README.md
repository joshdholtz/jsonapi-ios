# JSONAPI - iOS

[![Build Status](https://travis-ci.org/joshdholtz/jsonapi-ios.png?branch=master)](https://travis-ci.org/joshdholtz/jsonapi-ios)
![](https://cocoapod-badges.herokuapp.com/v/JSONAPI/badge.png)
[![Join the chat at https://gitter.im/joshdholtz/jsonapi-ios](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/joshdholtz/jsonapi-ios?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A library for loading data from a [JSON API](http://jsonapi.org) datasource. Parses JSON API data into models with support for linking of properties and other resources.

### Updates

Version | Changes
--- | ---
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

    pod 'JSONAPI', '~> 1.0.0'

## Usage

### JSONAPI
`JSONAPI` parses and validates a JSON API document into a usable object. This object holds the response as an NSDictionary but provides methods to accomdate the JSON API format such as `meta`, `errors`, `linked`, `resources`, and `includedResources`.

### JSONAPIResource
`JSONAPIResource` is an object (that gets subclassed) that holds data for each resource in a JSON API document. This objects holds the "id" as `ID` and link for self as `selfLink` as well as attributes and relationships defined by descriptors (see below)

#### Resource mappings (using descriptors)
`+ (JSONAPIResourceDescriptor*)descriptor` should be overwritten to define descriptors for mapping of JSON keys and relationships into properties of a subclassed JSONAPIResource.

##### Usage

````objc

@interface ArticleResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) PeopleResource *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *comments;

@end

@implementation ArticleResource

static JSONAPIResourceDescriptor *__descriptor = nil;

+ (JSONAPIResourceDescriptor*)descriptor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"articles"];

        [__descriptor setIdProperty:@"ID"];

        [__descriptor addProperty:@"title"];
        [__descriptor addProperty:@"date"
                 withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"date" withFormat:[NSDateFormatter RFC3339DateFormatter]]];

        [__descriptor hasOne:[PeopleResource class] withName:@"author"];
        [__descriptor hasMany:[CommentResource class] withName:@"comments"];
    });

    return __descriptor;
}

@end

````

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

JSONAPI is available under the MIT license. See the LICENSE file for more info.

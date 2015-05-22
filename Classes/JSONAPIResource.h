//
//  JSONAPIResource.h
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import <Foundation/Foundation.h>

@class JSONAPI;
@class JSONAPIPropertyDescriptor;
@class JSONAPIResourceDescriptor;

/** 
 * Protocol of an object that is available for JSON API serialization. 
 * 
 * When developing model classes for use with JSON-API, it is suggested that classes
 * be derived from <JSONAPIResourceBase>, but that is not required. An existing model
 * class can be adapted for JSON-API by implementing this protocol.
 */
@protocol JSONAPIResource <NSObject>

#pragma mark - Class Methods

/**
 Get the JSON API resource metadata description. This will be different for each resource
 model class. It must be defined by the subclass.

 The definition should look something like:
 
 <pre><code>
      #import &lt;JSONAPI/JSONAPIPropertyDescriptor.h&gt;
      #import &lt;JSONAPI/JSONAPIResourceDescriptor.h&gt;
 
      @implementation PeopleResource

      static JSONAPIResourceDescriptor *__descriptor = nil;

      + (JSONAPIResourceDescriptor*)descriptor {
         static dispatch_once_t onceToken;
         dispatch_once(&onceToken, ^{
           __descriptor = [[JSONAPIResourceDescriptor alloc] initWithClass:[self class] forLinkedType:@"people"];

           [__descriptor setIdProperty:@"ID"];

           [__descriptor addProperty:@"telephone"];
           [__descriptor addProperty:@"birthday" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"birthday" withFormat:[NSDateFormatter RFC3339DateFormatter]]];
           [__descriptor addProperty:@"firstName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"first"]];
           [__descriptor addProperty:@"lastName" withDescription:[[JSONAPIPropertyDescriptor alloc] initWithJsonName:@"last"]];
         });

         return __descriptor;
       }
 </code></pre>

 In this example, `PeopleResource` is a class that inherits from <JSONAPIResourceBase>
 (defines property 'ID'), and defines properties `NSString *telephone`, `NSDate *birthday`,
 `NSString *firstName` and `NSString *lastName`. 
 
 * The `telephone` property needs no special transform rules. 
 * The `birthday` property must be transformed into a string for JSON. 
 * The API you are targeting uses the labels `first` and `last` for the last two properties,
 which you prefer to relabel internally.

 @return Resource description for the target model class.
 */
+ (JSONAPIResourceDescriptor*)descriptor;


#pragma mark - Properties

/**
 * Get the URL that corresponds to this resource. May be nil. Should be set if returned from a
 * server. A GET request on the JSON-API endpoint should return the same resource.
 *
 * There should be no <JSONAPIPropertyDescriptor> for this property. It is set from the 'links'
 * property in the JSON body, and the JSON value is always a string URL.
 *
 * In general, this should be implemented by a @property selfLink in the realized class. The 
 * @property declaration will automatically synthesize the get/set members declared in this
 * protocol. The property storage is an implementation detail, which is why the protocol does  
 * not use a @property declaration.
 *
 * @return The URL that corresponds to this resource. 
 */
- (NSString *)selfLink;

/**
 * Set the URL that corresponds to this resource. This attribute is set from the 'links'
 * property in the JSON body, and the JSON value is always a string URL. A GET request on the 
 * JSON-API endpoint should return the same resource.
 *
 * In general, this should be implemented by a @property selfLink in the realized class. The
 * @property declaration will automatically synthesize the get/set members declared in this
 * protocol. The property storage is an implementation detail, which is why the protocol does
 * not use a @property declaration.
 *
 * @param path The URL that corresponds to this resource.
 */
- (void)setSelfLink:(NSString*)path;

/**
 * Get the API record identifier for a resource instance. Required for resources that come
 * from persistance storage (i.e. the server), but may be nil for new records that have not
 * been saved. Every saved resource record should be uniquely identifiable by the combination
 * of type and ID.
 *
 * This is typically a database sequence number associated withe the resource record, 
 * but that is not required. The JSON API requires ID to be serialized as a string.
 *
 * In general, this should be implemented by a @property ID in the realized class. The
 * @property declaration will automatically synthesize the get/set members declared in this
 * protocol. The property storage is an implementation detail, which is why the protocol does
 * not use a @property declaration.
 *
 * @return The record identifier for a resource instance.
 */
- (id)ID;

/**
 * Set the API record identifier for a resource instance. Required for resources that come
 * from persistance storage (i.e. the server), but may be nil for new records that have not
 * been saved. Every saved resource record should be uniquely identifiable by the combination
 * of type and ID.
 *
 * This is typically a database sequence number associated withe the resource record,
 * but that is not required. The JSON API requires ID to be serialized as a string.
 *
 * In general, this should be implemented by a @property ID in the realized class. The
 * @property declaration will automatically synthesize the get/set members declared in this
 * protocol. The property storage is an implementation detail, which is why the protocol does
 * not use a @property declaration.
 *
 * @param identifier The record identifier for a resource instance.
 */
- (void)setID:(id)identifier;


@end

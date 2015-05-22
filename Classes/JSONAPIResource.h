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
 * When developing model classes for use with JSON-API, it is reccomended that classes 
 * are derived from <JSONAPIResourceBase>, but that is not required. An existing model
 * class can be adapted for JSON-API by implementing this protocol.
 */
@protocol JSONAPIResource <NSObject>

#pragma mark - Class Methods

/**
 * Get the JSON API resource metadata description. This will be different for each resource 
 * model class. It must be defined by the subclass.
 *
 * @return Resource description for the target model class.
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

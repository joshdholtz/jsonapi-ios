//
//  JSONAPIResourceBase.h
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import <Foundation/Foundation.h>

#include "JSONAPIResource.h"

/**
 * Model classes that are developed with JSON-API in mind may be derived from this abstract
 * base class. This implements the required properties for a JSON-API model resource.
 *
 * The descriptor for a model resource is not implemented, and must be declared in the 
 * realized model class.
 */
@interface JSONAPIResourceBase : NSObject <JSONAPIResource>

/**
 * The URL that corresponds to this resource. May be nil. Should be set if returned from a
 * server.
 *
 * There is no <JSONAPIPropertyDescriptor> for this property. It is set from the 'links'
 * property in the JSON body, and the JSON value is always a string URL.
 */
@property (strong, nonatomic) NSString *selfLink;

/**
 * API identifier for a resource instance. Required for resources that come from the
 * server, but may be nil for new records that have not been saved. Every saved
 * record should be uniquely identifiable by the combination of type and ID.
 *
 * This is typically a database sequence number associated withe the resource record,
 * but that is not required. The JSON API requires ID to be serialized as a string.
 *
 * @warning Each subclass must add this property to its <JSONAPIResourceDescriptor> with the line:
 *
 *      \[descriptor setIdProperty:@"ID"\];
 *
 * where 'descriptor' is the name of your classes' static <JSONAPIResourceDescriptor>.
 */
@property (strong, atomic) id ID;

/**
 * Meta for a resource instance. Optional for resources that come
 * from persistance storage (i.e. the server).
 */
@property (strong, atomic) NSDictionary *meta;

@end

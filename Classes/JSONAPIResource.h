//
//  JSONAPIResource.h
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONAPI;
@class JSONAPIPropertyDescriptor;
@class JSONAPIResourceDescriptor;

/*! Base class of an object that is available for JSON API serialization. */
@interface JSONAPIResource : NSObject<NSCopying, NSCoding>


#pragma mark - Properties

/*!
 * The URL that corresponds to this resource. Not required. May be set if returned from a
 * server.
 *
 * There is no JSONAPIPropertyDescriptor for this property. It is set from the 'links'
 * property in the JSON body, and the JSON value is always a string URL.
 */
@property (nonatomic, copy) NSString *self_link;

/*!
 * API identifier for a resource instance. Required for resources that come from the
 * server, but the should be nil for new records that have not been saved. Every saved
 * record should be uniquely identifiable by the combination of type and ID.
 *
 * This is typically a database sequence number associated withe the resource record, 
 * but that is not required. The JSON API requires ID to be serialized as a string.
 *
 * A JSONAPIPropertyDescriptor for the ID will automatically be included in the default
 * JSONAPIResourceDescriptor for the class. This descriptor does not covert the string 
 * value received, but you can set a formatter on the property descriptor if desired.
 */
@property (nonatomic, strong) id ID;


#pragma mark - Class methods

/*! 
 * Allocate a resource object from a JSON dictionary. The dictionary argument should
 * describe one resource in JSON API format. This can be a JSON API "data" element,
 * one of the JSON API "included" elemets, or even a "linkage" element. A valid
 * dictionary contains at least "type" and "id" fields.
 *
 * TODO: spec allows a resource to be specified by a 'related resource URL'.
 *
 * @param dictionary JSON instance definition as NSDictionary
 *
 * @param newly allocated JSONAPIResource subclass instance.
 */
+ (instancetype)jsonAPIResource:(NSDictionary*)dictionary;

/*! 
 * Allocate an array of resource objects. The array argument must be an array of dictionary 
 * objects follwing the same rules for a single resource.
 *
 * @param array array of dictionary JSON instance definition as NSDictionary.
 * 
 * @return Array of newly allocated JSONAPIResource subclass instances.
 */
+ (NSArray*)jsonAPIResources:(NSArray*)array;

/*! 
 * Get the JSONAPI resource metadata description. This will be different for each resource class. 
 * It must be defined by the subclass.
 *
 * @return Resource description for the target class.
 */
+ (JSONAPIResourceDescriptor*)descriptor;


#pragma mark - Instance methods

/*! 
 * Initialize an object from a deserialized JSON API dictionary.
 *
 * In general, there is enough information in the class JSONAPIResourceDescriptor for the
 * base method to construct any subclass, so you do not need to override this method.
 *
 * @param dict JSON instance definition as NSDictionary
 *
 * @param initialized JSONAPIResource subclass instance.
 */
- (instancetype)initWithDictionary:(NSDictionary*)dict;

/*! 
 * Update the linked resources from a deserialized set of JSON API "included" elements. 
 * Linked resource instances are replaced with full definition, when type and ID match.
 *
 * @param jsonAPI Message body as JSONAPI.
 */
- (void)linkWithIncluded:(JSONAPI*)jsonAPI;

/*! 
 * Serialize resource to a JSON dictionary. 
 * 
 * @return NSDictionary that fully describes this instance. This is ready to include in 
 * a JSON API message 'data' set or 'included' set.
 */
- (NSDictionary*)dictionary;

/*!
 * Get array of associated resource instances.
 *
 * @return The collection of related JSONAPIResource instances.
 */
- (NSArray*)relatedResources;

@end

//
//  JSONAPIResourceParser.h
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import <Foundation/Foundation.h>

#import "JSONAPIResource.h"

@class JSONAPI;

/** Class to perform serialization and deserialization of JSON-API to model. */
@interface JSONAPIResourceParser : NSObject


#pragma mark - Class methods

/**
 * Allocate a resource object from a JSON dictionary. The dictionary argument should
 * describe one resource in JSON API format. This can be a JSON API "data" element,
 * one of the JSON API "included" elemets, or even a "linkage" element. A valid
 * dictionary contains at least "type" and "id" fields.
 *
 * TODO: spec allows a resource to be specified by a 'related resource URL'.
 *
 * @param dictionary JSON instance definition as NSDictionary
 *
 * @return newly allocated <JSONAPIResource> model instance.
 */
+ (id <JSONAPIResource>)parseResource:(NSDictionary*)dictionary;

/**
 * Allocate an array of resource objects. The array argument must be an array of
 * dictionary objects follwing the same rules for a single resource.
 *
 * @param array array of dictionary JSON instance definition as NSDictionary.
 *
 * @return Array of newly allocated <JSONAPIResource> model instances.
 */
+ (NSArray*)parseResources:(NSArray*)array;

/**
 * Serialize resource to a JSON dictionary.
 *
 * @return NSDictionary that fully describes this instance. This is ready to include in
 * a JSON-API message 'data' set or 'included' set.
 *
 * @param resource model object
 */
+ (NSDictionary*)dictionaryFor:(NSObject <JSONAPIResource>*)resource;

/**
 * Initialize the instance properties in the model object instance from the JSON 
 * dictionary.
 * 
 * @warning The caller is responsible for insuring the resource class matches the
 * dictionary type. Results of mismatched types are unpredictable.
 *
 * @param resource model object
 * @param dictionary JSON-API data dictionary
 */
+ (void)set:(NSObject <JSONAPIResource> *)resource withDictionary:dictionary;

/**
 * Update the linked resources from a deserialized set of JSON API "included" elements.
 * Linked resource instances are replaced with full definition, when type and ID match.
 *
 * @param resource model object
 * @param jsonAPI JSON-API message object
 */
+ (void)link:(NSObject <JSONAPIResource>*)resource withIncluded:(JSONAPI*)jsonAPI;

/**
 * Get array of associated resource instances.
 *
 * @param resource model object
 *
 * @return The collection of related <JSONAPIResource> model instances.
 */
+ (NSArray*)relatedResourcesFor:(NSObject <JSONAPIResource>*)resource;

@end

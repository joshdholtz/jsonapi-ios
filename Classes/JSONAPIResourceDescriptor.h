//
//  JSONAPIResourceDescriptor.h
//  JSONAPI
//

#import <Foundation/Foundation.h>

@class JSONAPIPropertyDescriptor;

/**
 * Metadata for a <JSONAPIResource> class. Describes the JSON attributes for a the class.
 */
@interface JSONAPIResourceDescriptor : NSObject

/** JSON-API "type" name */
@property (readonly) NSString *type;

/** The resource class that is described */
@property (readonly) Class resourceClass;

/** Maps property names to <JSONAPIPropertyDescriptor> */
@property (readonly) NSDictionary *properties;

/**
 * Register a resouce type.
 *
 * @param resourceClass The class represented. Must be a subclass of<JSONAPIResource>.
 */
+ (void)addResource:(Class)resourceClass;

/**
 * Get the resource descriptor for the JSON "type" label.
 *
 * @param linkedType The label associated with the resource class in JSON
 *
 * @return The resource class descriptor.
 */
+ (instancetype)forLinkedType:(NSString *)linkedType;

/**
 * Initialize a new instance.
 *
 * @param resource A <JSONAPIResource> class
 * @param linkedType Label used in JSON for type
 */
- (instancetype)initWithClass:(Class)resource forLinkedType:(NSString*)linkedType;

/**
 * Add a <JSONAPIPropertyDescriptor> for a simple property.
 *
 * The default property description assumes the property name matches the JSON name,
 * and no string format is used.
 *
 * @param name The name of the property in the class.
 */
- (void)addProperty:(NSString*)name;

/**
 * Add a <JSONAPIPropertyDescriptor> for a simple property with custom transform object.
 *
 * @param name The name of the property in the class.
 * @param description Describes how the property is transformed to JSON
 */
- (void)addProperty:(NSString*)name withDescription:(JSONAPIPropertyDescriptor*)description;

/**
 * Add a <JSONAPIPropertyDescriptor> for a has-one related resource property.
 *
 * The default property description assumes the property name matches the JSON label.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 */
- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name;

/**
 * Add a <JSONAPIPropertyDescriptor> for a has-one related resource property with a 
 * JSON property label different from the property name.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 * @param json The label of the property in JSON
 */
- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json;

/**
 * Add a <JSONAPIPropertyDescriptor> for a has-many related resource property.
 *
 * The default property description assumes the property name matches the JSON label.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 */
- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name;

/**
 * Add a <JSONAPIPropertyDescriptor> for a has-many related resource property with a 
 * JSON property label different from the property name.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 * @param json The label of the property in JSON
 */
- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json;

@end

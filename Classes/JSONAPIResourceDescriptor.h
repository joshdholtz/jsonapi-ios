//
//  JSONAPIResourceDescriptor.h
//  JSONAPI
//

#import <Foundation/Foundation.h>

@class JSONAPIPropertyDescriptor;

/**
 * Describes the JSON attributes for a resource class.
 */
@interface JSONAPIResourceDescriptor : NSObject

/** JSON-API type name */
@property (readonly) NSString *type;

/** The resource class described */
@property (readonly) Class resourceClass;

/** Maps property names to JSONAPIProperty */
@property (readonly) NSDictionary *properties;

/**
 * Register a resouce type.
 *
 * @param resourceClass The class represented. Must be a subclass of
 *      JSONAPIResource.
 */
+ (void)addResource:(Class)resourceClass;

/**
 * Get the resource descriptor for the JSON type label.
 *
 * @param linkedType The label associated with the resource class in JSON
 *
 * @return The resource class descriptor.
 */
+ (instancetype)forLinkedType:(NSString *)linkedType;

/**
 * Initialize a new instance.
 *
 * Starts automatically with an "ID" property. This resolves the "ID" property for the
 * base class JSONAPIResource. Subclasses must use the instance methods to add their
 * properties.
 *
 * @param resource A JSONAPIResource class
 * @param linkedType Label used in JSON for type
 */
- (instancetype)initWithClass:(Class)resource forLinkedType:(NSString*)linkedType;

/**
 * Add a JSONAPIPropertyDescriptor for a simple property.
 *
 * The default property description assumes the property name matches the JSON name,
 * and no string format is used.
 *
 * @param name The name of the property in the class.
 */
- (void)addProperty:(NSString*)name;

/**
 * Add a JSONAPIPropertyDescriptor for a simple property.
 *
 * @param name The name of the property in the class.
 * @param description Describes how the property is transformed to JSON
 */
- (void)addProperty:(NSString*)name withDescription:(JSONAPIPropertyDescriptor*)description;

/**
 * Add a JSONAPIPropertyDescriptor for a has-one related resource property.
 *
 * The default property description assumes the property name matches the JSON label.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 */
- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name;

/**
 * Add a JSONAPIPropertyDescriptor for a has-one related resource property.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 * @param json The label of the property in JSON
 */
- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json;

/**
 * Add a JSONAPIPropertyDescriptor for a has-many related resource property.
 *
 * The default property description assumes the property name matches the JSON label.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 */
- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name;

/**
 * Add a JSONAPIPropertyDescriptor for a has-many related resource property.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 * @param json The label of the property in JSON
 */
- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json;

@end

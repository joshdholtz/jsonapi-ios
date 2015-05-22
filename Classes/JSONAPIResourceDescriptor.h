//
//  JSONAPIResourceDescriptor.h
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import <Foundation/Foundation.h>

@class JSONAPIPropertyDescriptor;

/**
 * Metadata for a <JSONAPIResource> class. Describes the JSON attributes for a the class.
 */
@interface JSONAPIResourceDescriptor : NSObject

#pragma mark - Properties

/** 
 * JSON-API "type" name 
 *
 * This is required for any model resource.
 */
@property (strong, readonly) NSString *type;

/**
 * JSON-API "id" property description.
 *
 * This is required for any model resource.
 */
@property (strong) NSString *idProperty;

/** 
 * JSON-API "id" optional format. 
 *
 * JSON-API requires the 'id' property to be serialized as a string. The formatter
 * allows you to specify any convertable object. If the property is nil, the 'id' 
 * will use the default JSON serialization.
 */
@property (strong) NSFormatter *idFormatter;

/** The resource class that is described. */
@property (readonly) Class resourceClass;

/** Maps model property names to <JSONAPIPropertyDescriptor>. */
@property (readonly) NSDictionary *properties;


#pragma mark - Class Methods

/**
 * Register a resouce type.
 * 
 * This must be called before any serious parsing can be done. You must add a line
 * for each resource class like:
 *
 *          \[JSONAPIResourceDescriptor addResource:\[PeopleResource class\]\];
 *
 * somewhere in your test/application setup. This is all you have to do to configure this 
 * module.
 *
 * @param resourceClass The class represented. Must implement the <JSONAPIResource> protocol.
 */
+ (void)addResource:(Class)resourceClass;

/**
 * Get the resource descriptor for the JSON "type" label.
 *
 * This only works if the <JSONAPIResource> class has been registered first.
 *
 * @param linkedType The label associated with the resource class in JSON
 *
 * @return The resource class descriptor.
 */
+ (instancetype)forLinkedType:(NSString *)linkedType;


#pragma mark - Instance Methods

/**
 * Initialize a new instance.
 *
 * @param resource A <JSONAPIResource> class
 * @param linkedType Label used in JSON for type
 */
- (instancetype)initWithClass:(Class)resource forLinkedType:(NSString*)linkedType;

/**
 * Add a simple property.
 *
 * Creates a default <JSONAPIPropertyDescriptor> based on the name. The default property 
 * description assumes the JSON name matches the property name, and no string format is used.
 *
 * @param name The name of the property in the model class.
 */
- (void)addProperty:(NSString*)name;

/**
 * Add a simple property with custom transform object.
 *
 * @param name The name of the property in the class.
 * @param description Describes how the property is transformed to JSON
 */
- (void)addProperty:(NSString*)name withDescription:(JSONAPIPropertyDescriptor*)description;

/**
 * Add a has-one related resource property.
 *
 * Creates a default <JSONAPIPropertyDescriptor> based on the name. The default property
 * description assumes the JSON name matches the property name.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 */
- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name;

/**
 * Add a has-one related resource property with a JSON property label different from 
 * the property name.
 *
 * Creates a <JSONAPIPropertyDescriptor> based on the arguments.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 * @param json The label of the property in JSON
 */
- (void)hasOne:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json;

/**
 * Add a has-many related resource property.
 *
 * Note that the Class argmuent refers to the collection element type. It assumes the
 * property is instantiated in an NSArray.
 *
 * Creates a default <JSONAPIPropertyDescriptor> based on the name. The default property
 * description assumes the JSON name matches the property name.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 */
- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name;

/**
 * Add a has-many related resource property with a JSON property label different from 
 * the property name.
 *
 * Note that the Class argmuent refers to the collection element type. It assumes the
 * property is instantiated in an NSArray.
 *
 * Creates a <JSONAPIPropertyDescriptor> based on the arguments.
 *
 * @param jsonApiResource The related property class.
 * @param name The name of the property in the class.
 * @param json The label of the property in JSON
 */
- (void)hasMany:(Class)jsonApiResource withName:(NSString*)name withJsonName:(NSString*)json;

@end

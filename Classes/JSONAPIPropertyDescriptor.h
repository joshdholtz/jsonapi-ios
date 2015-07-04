//
//  JSONAPIProperty.h
//  JSONAPI
//
//  Created by Jonathan Karl Armstrong, 2015.
//

#import <Foundation/Foundation.h>

@class JSONAPIResourceDescriptor;

/**
 * JSON API metadata for a <JSONAPIResource> property. This is intended to be used in 
 * dictionary contained in <JSONAPIResourceDescriptor>. The dictionary key is the model 
 * class property name, and the <JSONAPIResourceDescriptor> contains the rest of the 
 * model class metadata.
 *
 * This class is used primarily to transform an individual model property to and from JSON.
 *
 * There are two basic resouce model property types; simple values and related resource 
 * references. This class handles both, although some internal properties may only apply 
 * to one or the other.
 * 
 * A simple value property includes anything that can be expressed or transformed into 
 * a single key-value pair in JSON. This includes types like NSNumber and NSString that 
 * have native JSON serialization support, as well as types like NSDate that can be 
 * transformed into an NSString representation using an NSFormatter.
 *
 * Related resources are objects that must also conform to the <JSONAPIResource> protocol. 
 * Classes that do not conform to the protocol, or do not have a <JSONAPIResourceDescriptor>
 * registered at runtime, are not supported, even if they theoretically have a valid JSON 
 * serialization. Since it is easy to implement the protocol on existing classes, this 
 * should not be a great limitation.
 */
@interface JSONAPIPropertyDescriptor : NSObject

/** 
 * Name used for property in JSON serialization 
 */
@property (nonatomic, readonly) NSString *jsonName;

/** 
 * Optional formatter instance used to serialize/deserialize property. For example,
 * NSDate instances must be serialized to a string representation. Any type that can be
 * reversibly serialized to a String can be used as a property by setting an appropriate 
 * serializer.
 *
 * For array properties, this is applied to each element of an array if set.
 *
 * Formatters are only for simple property types. A _linked_ <JSONAPIResource> may not have 
 * a formatter.
 */
@property (nonatomic) NSFormatter *formatter;

/**
 * For a linked <JSONAPIResource> type, this is a reference to the resource class.
 *
 * For array properties (has many relationship), this applies to each element of the array.
 *
 * Should be nil for simple types.
 */
@property (nonatomic, readonly) Class resourceType;

/** 
 * Initialize new instance. For supported simple types (NSSTring, NSNumber, etc.) this is usually 
 * sufficient.
 *
 * @param name property label used in JSON
 */
- (instancetype)initWithJsonName:(NSString*)name;

/** 
 * Initialize new instance with NSFormatter. For simple properties that are not directly
 * supported by NSJSONSerialization, use this. For example, NSDate requires an NSDateFormatter.
 *
 * @param name property label used in JSON
 * @param fmt an NSFormatter that converts to/fram JSON string
 */
- (instancetype)initWithJsonName:(NSString*)name withFormat:(NSFormatter*)fmt;

/** 
 * Initialize new instance for linked resource property. For related resource properties use this.
 * This applies to both has-one relationships and has-many relationships.
 *
 * @param name property label used in JSON
 * @param resource Class of property. If property is an array (has_many), this is the element Class.
 */
- (instancetype)initWithJsonName:(NSString*)name withResource:(Class)resource;

@end

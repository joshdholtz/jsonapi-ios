//
//  JSONAPIProperty.h
//  JSONAPI
//

#import <Foundation/Foundation.h>

@class JSONAPIResourceDescriptor;

/*!
 * JSON API metadata for a JSONAPIResource property
 */
@interface JSONAPIPropertyDescriptor : NSObject

/*! Name used for "type" in JSON serialization */
@property (nonatomic, readonly) NSString *jsonName;

/*! 
 * Optional reference used to serialize/deserialize property. For example, NSDate instances must be
 * serialized to a string representation. Any type that can be reversibly serialized to a String can
 * be used as a property by setting an appropriate serializer.
 *
 * For array properties, this is applied to each element of an array if set.
 *
 * Formatters are only for simple property types. A linked JSONAPIResource may not have a formatter.
 */
@property (nonatomic) NSFormatter *formatter;

/*!
 * For a linked JSONAPIResource type, this is a reference to the resource class.
 *
 * For array properties (has many relationship), this applies to each element of the array.
 *
 * Should be nil for simple types.
 */
@property (nonatomic, readonly) Class resourceType;

/*! 
 * Initialize new instance. For supported simple types (NSSTring, NSNumber, etc.) this is usually 
 * sufficient.
 */
- (instancetype)initWithJsonName:(NSString*)name;

/*! 
 * Initialize new instance with NSFormatter. For simple properties that are not directly
 * supported by NSJSONSerialization, use this. For example, NSDate requires an NSDateFormatter.
 */
- (instancetype)initWithJsonName:(NSString*)name withFormat:(NSFormatter*)fmt;

/*! 
 * Initialize new instance for linked resource property. For related resource properties use this.
 * This applies to both has-one relationships and has-many relationships.
 */
- (instancetype)initWithJsonName:(NSString*)name withResource:(Class)resource;

@end

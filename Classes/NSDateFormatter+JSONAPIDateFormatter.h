//
//  NSDateFormatter+JSONAPIDateFormatter.h
//

#import <Foundation/Foundation.h>

/**
 * Adds RFC 3339 formater to NSDateFormatter
 */
@interface NSDateFormatter (JSONAPIDateFormatter)

/**
 * NSDate formatter that conforms to RFC 3339. This is a common JSON convention for dates.
 * Format string is "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'".
 */
+ (instancetype)RFC3339DateFormatter;

@end

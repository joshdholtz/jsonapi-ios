//
//  NSDateFormatter+JSONAPIDateFormatter.h
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (JSONAPIDateFormatter)

/**
 * NSDate formatter that conforms to RFC 3339. This is a very common JSON convention for dates.
 */
+ (instancetype)RFC3339DateFormatter;

@end

//
//  NSDateFormatter+HUMDefaultDateFormatter.h
//  HumonX
//
//  Created by Jonathan Karl Armstrong on 3/28/15.
//  Copyright (c) 2015 Jonathan Karl Armstrong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (JSONAPIDateFormatter)

/*!
 * NSDate formatter that conforms to RFC 3339. This is a very common JSON convention for dates.
 */
+ (instancetype)RFC3339DateFormatter;

@end

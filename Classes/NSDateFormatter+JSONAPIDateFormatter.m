//
//  NSDateFormatter+JSONAPIDateFormatter.m
//

#import "NSDateFormatter+JSONAPIDateFormatter.h"

@implementation NSDateFormatter (JSONAPIDateFormatter)

+ (instancetype)RFC3339DateFormatter
{
  static NSDateFormatter *dateFormatter = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"];
    
    [dateFormatter setLocale: enUSPOSIXLocale];
    [dateFormatter setDateFormat: @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT: 0]];
  });
  
  return dateFormatter;
}

@end

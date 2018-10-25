//
//  JSONAPIResourceFactory.h
//  JSONAPI
//
//  Created by V-Ken Chin on 11/4/18.
//  Copyright © 2018 Josh Holtz. All rights reserved.
//

#ifndef JSONAPIResourceFactory_h
#define JSONAPIResourceFactory_h

#import "JSONAPIResource.h"
@protocol JSONAPIResourceFactory <JSONAPIResource>
+ (id<JSONAPIResource>)resourceObjectFor:(NSDictionary *)dictionary;
@end
#endif /* JSONAPIResourceFactory_h */

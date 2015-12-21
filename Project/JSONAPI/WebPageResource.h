//
//  WebPageResource.h
//  JSONAPI
//
//  Created by Rafael Kayumov on 14.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceBase.h"

@interface WebPageResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *pageUrl;

@end

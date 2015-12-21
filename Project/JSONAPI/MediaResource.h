//
//  MediaResource.h
//  JSONAPI
//
//  Created by Rafael Kayumov on 14.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceBase.h"

@interface MediaResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *fileUrl;

@end

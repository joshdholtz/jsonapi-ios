//
//  UserResource.h
//  JSONAPI
//
//  Created by Rafael Kayumov on 13.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceBase.h"

@interface UserResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;

@end

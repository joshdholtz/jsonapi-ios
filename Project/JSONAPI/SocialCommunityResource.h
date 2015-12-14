//
//  SocialCommunityResource.h
//  JSONAPI
//
//  Created by Rafael Kayumov on 14.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceBase.h"

@interface SocialCommunityResource : JSONAPIResourceBase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *homePage;

@end

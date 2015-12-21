//
//  NewsFeedPostResource.h
//  JSONAPI
//
//  Created by Rafael Kayumov on 13.12.15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

#import "JSONAPIResourceBase.h"
#import "UserResource.h"
#import "SocialCommunityResource.h"
#import "MediaResource.h"
#import "WebPageResource.h"

@interface NewsFeedPostResource : JSONAPIResourceBase

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) id<JSONAPIResource> publisher;
@property (nonatomic, strong) NSArray *attachments;

@end

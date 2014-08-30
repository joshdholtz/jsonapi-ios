//
//  ViewController.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/23/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "ViewController.h"

#import "JSONAPI.h"

#import "CommentResource.h"
#import "PeopleResource.h"
#import "PostResource.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JSONAPI setIsDebuggingEnabled:TRUE];
    
    // Linking
    [[JSONAPIResourceLinker defaultInstance] link:@"author" toLinkedType:@"people"];
    
    // Modeling
    [[JSONAPIResourceModeler defaultInstance] useResource:[CommentResource class] toLinkedType:@"comments"];
    [[JSONAPIResourceModeler defaultInstance] useResource:[PeopleResource class] toLinkedType:@"people"];
    [[JSONAPIResourceModeler defaultInstance] useResource:[PostResource class] toLinkedType:@"posts"];
    
    // Formatting
    [[JSONAPIResourceFormatter defaultInstance] registerFormat:@"Date" withBlock:^id(id jsonValue) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        NSDate *date = nil;
        NSError *error = nil;
        if (![dateFormatter getObjectValue:&date forString:jsonValue range:nil error:&error]) {
            NSLog(@"Date '%@' could not be parsed: %@", jsonValue, error);
        }
        
        return date;
    }];
	
    // Parsing using JSONAPI and JSONAPIResource
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:[self authorResponse]];
    
    NSLog(@"------------ Parsing using JSONAPI, modeled resources, and mapped properties (PostResource, PeopleResource, CommentResource");
    NSArray *posts = [jsonApi resourcesForKey:@"posts"];
    
    // Parsing using JSONAPI, modeled resources, and mapped properties (PostResource, PeopleResource, CommentResource
    for (PostResource *post in posts) {
        
        PeopleResource *author = post.author;
        NSLog(@"\"%@\" by %@ on %@", post.name, author.name, post.date);
        
        NSArray *comments = post.comments;
        for (CommentResource *comment in comments) {
            NSLog(@"\t%@", comment.text);
        }
    }
}

#pragma mark - Response Generator

- (NSDictionary*)authorResponse {
    NSDictionary *meta = @{ @"page_number" : @1, @"number_of_pages" : @5};
    NSDictionary *linked = @{ @"people" : @[
                                      @{ @"id" : @9, @"name" : @"Josh Holtz" },
                                      @{ @"id" : @10, @"name" : @"Bandit the Cat" }
                                      ],
                              @"comments" : @[
                                      @{ @"id" : @2, @"text" : @"Omg this post is awesome" },
                                      @{ @"id" : @3, @"text" : @"Omg this post is awesomer" },
                                      @{ @"id" : @4, @"text" : @"Meeeehhhhh" }
                                      ]};
    
    NSDictionary *post1 = @{ @"id" : @1, @"name" : @"Josh is awesome", @"date" : @"2013-10-14T05:34:32+600", @"links" : @{ @"author" : @9, @"comments" : @[ @2, @3 ] } };
    NSDictionary *post2 = @{ @"id" : @2, @"name" : @"Bandit is awesome", @"date" : @"2013-10-14T05:34:32+600", @"links" : @{ @"author" : @10, @"comments" : @[ @4 ] } };
    
    NSArray *posts = @[ post1, post2 ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    return json;
}

@end

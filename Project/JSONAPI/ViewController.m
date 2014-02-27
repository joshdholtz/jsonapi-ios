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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup
    [JSONAPIResourceLinker link:@"author" toLinkedType:@"people"];
    [JSONAPIResourceModeler useResource:[CommentResource class] toLinkedType:@"comments"];
    [JSONAPIResourceModeler useResource:[PeopleResource class] toLinkedType:@"people"];
    [JSONAPIResourceModeler useResource:[PostResource class] toLinkedType:@"posts"];
	
    // Parsing using JSONAPI and JSONAPIResource
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:[self authorResponse]];
    
    NSLog(@"------------ Parsing using JSONAPI and JSONAPIResource");
    NSArray *posts = [jsonApi resourcesForKey:@"posts"];
    for (JSONAPIResource *post in posts) {
        
        JSONAPIResource *author = [post linkedResourceForKey:@"author"];
        NSLog(@"\"%@\" by %@", [post objectForKey:@"name"], [author objectForKey:@"name"]);
        
        NSArray *comments = [post linkedResourceForKey:@"comments"];
        for (JSONAPIResource *comment in comments) {
            NSLog(@"\t%@", [comment objectForKey:@"text"]);
        }
    }
    
    // Parsing using JSONAPI and modeled resources (PostResource, PeopleResource, CommentResource
    NSLog(@"\n\n------------ Parsing using JSONAPI and modeled resources (PostResource, PeopleResource, CommentResource");
    for (PostResource *post in posts) {
        
        PeopleResource *author = post.author;
        NSLog(@"\"%@\" by %@", post.name, author.name);
        
        NSArray *comments = post.comments;
        for (CommentResource *comment in comments) {
            NSLog(@"\t%@", comment.text);
        }
    }
    
    // Parsing using JSONAPI, modeled resources, and mapped properties (PostResource, PeopleResource, CommentResource
    NSLog(@"\n\n------------ Parsing using JSONAPI, modeled resources, and mapped properties (PostResource, PeopleResource, CommentResource");
    for (PostResource *post in posts) {
        
        PeopleResource *author = post.author;
        NSLog(@"\"%@\" by %@", post.mapName, author.mapName);
        
        NSArray *comments = post.mapComments;
        for (CommentResource *comment in comments) {
            NSLog(@"\t%@", comment.mapText);
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSDictionary *post1 = @{ @"id" : @1, @"name" : @"Josh is awesome", @"links" : @{ @"author" : @9, @"comments" : @[ @2, @3 ] } };
    NSDictionary *post2 = @{ @"id" : @2, @"name" : @"Bandit is awesome", @"links" : @{ @"author" : @10, @"comments" : @[ @4 ] } };
    
    NSArray *posts = @[ post1, post2 ];
    NSDictionary *json = @{ @"meta" : meta, @"linked" : linked, @"posts" : posts };
    
    return json;
}

@end

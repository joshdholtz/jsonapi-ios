//
//  JSONAPIDeveloperAssistant.h
//  JSONAPI
//
//  Created by Brennan Stehling on 7/10/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONAPIDeveloperAssistant : NSObject

+ (JSONAPIDeveloperAssistant *)defaultDeveloperAssistant;
+ (void)resetDefaultDeveloperAssistant;

+ (void)setDevelopmentModeEnabled:(BOOL)enabled;
+ (BOOL)isDevelopmentModeEnabled;

// all json keys are added to mapping store
- (void)addJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className;

// json keys which were mapped to properties
- (void)addMappedJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className;
// json keys which were not mapped to properties
- (void)addUnmappedJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className;

- (NSArray *)mappedKeysForClassName:(NSString *)className;
- (NSArray *)unmappedKeysForClassName:(NSString *)className;

- (void)logMappedModels;

@end

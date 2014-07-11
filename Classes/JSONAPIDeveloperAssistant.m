//
//  JSONAPIDeveloperAssistant.m
//  JSONAPI
//
//  Created by Brennan Stehling on 7/10/14.
//  Copyright (c) 2014 Josh Holtz. All rights reserved.
//

// Notes:
// Developer Assistant is used when Development Mode is enabled.
// Models which are mapped are recored by the Developer Assistant
// with each key that is mapped and not mapped. The purpose of the
// DA will be to help the developer discover which JSON values are
// not being mapped and to facilitate with adding those mappings
// to the models.
//
// The mapping will be the following:
// Class Name -> mapped json keys
//            -> unmapped json keys

#import "JSONAPIDeveloperAssistant.h"

#define kModelsKey @"models"
#define kAllKey @"all"
#define kMappedKey @"mapped"
#define kUnmappedKey @"unmapped"

#pragma mark - Class Extension
#pragma mark -

@interface JSONAPIDeveloperAssistant ()

@property (strong, nonatomic) NSMutableDictionary *mappedModels;

@end

@implementation JSONAPIDeveloperAssistant {
    BOOL _isPruned;
}

static BOOL _isDevelopmentModeEnabled = FALSE;

static JSONAPIDeveloperAssistant *_defaultDeveloperAssistant;

#pragma mark - Public
#pragma mark -

+ (JSONAPIDeveloperAssistant *)defaultDeveloperAssistant {
    if (!_defaultDeveloperAssistant) {
        _defaultDeveloperAssistant = [[JSONAPIDeveloperAssistant alloc] init];
        NSDictionary *mappedModels = @{ kModelsKey : @{}.mutableCopy };
        _defaultDeveloperAssistant.mappedModels = mappedModels.mutableCopy;
        
    }
    
    return _defaultDeveloperAssistant;
}

+ (void)resetDefaultDeveloperAssistant {
    _defaultDeveloperAssistant = nil;
}

+ (void)setDevelopmentModeEnabled:(BOOL)enabled {
    _isDevelopmentModeEnabled = enabled;
}

+ (BOOL)isDevelopmentModeEnabled {
    return _isDevelopmentModeEnabled;
}

- (void)addJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className {
    [self addJsonKey:jsonKey withPropertyName:propertyName forClassName:className inGroup:kAllKey];
}

- (void)addMappedJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className {
    [self addJsonKey:jsonKey withPropertyName:propertyName forClassName:className inGroup:kMappedKey];
}

- (void)addUnmappedJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className {
    [self addJsonKey:jsonKey withPropertyName:propertyName forClassName:className inGroup:kUnmappedKey];
}

- (void)logMappedModels {
    [self prune];
    
    NSLog(@"#### Mapped Models ####");
    NSLog(@"%@", self.mappedModels[kModelsKey]);
}

- (NSArray *)mappedKeysForClassName:(NSString *)className {
    [self prune];
    
    NSDictionary *mapped = self.mappedModels[kModelsKey][className][kMappedKey];
    if (mapped) {
        return mapped.allKeys;
    }
    else {
        return nil;
    }
}

- (NSArray *)unmappedKeysForClassName:(NSString *)className {
    [self prune];
    
    NSDictionary *unmapped = self.mappedModels[kModelsKey][className][kUnmappedKey];
    if (unmapped) {
        return unmapped.allKeys;
    }
    else {
        return nil;
    }
}

#pragma mark - Private
#pragma mark -

- (void)addJsonKey:(NSString *)jsonKey withPropertyName:(NSString *)propertyName forClassName:(NSString *)className inGroup:(NSString *)groupName {
    if (!jsonKey.length || !propertyName.length || !className.length || !groupName.length) {
        NSLog(@"WARNING: Attempted to add invalid values to Developer Assistant mapping");
        return;
    }

    // do not map the standard json keys
    if ([@"id" isEqualToString:jsonKey] || [@"href" isEqualToString:jsonKey] || [@"links" isEqualToString:jsonKey] || [@"meta" isEqualToString:jsonKey]) {
        return;
    }
    
    NSMutableDictionary *models = self.mappedModels[kModelsKey];
    
    NSMutableDictionary *model = nil;
    if (!models[className]) {
        model = @{}.mutableCopy;
        models[className] = model;
    }
    else {
        model = models[className];
    }
    
    NSMutableDictionary *group = nil;
    if (!model[groupName]) {
        group = @{}.mutableCopy;
        model[groupName] = group;
    }
    else {
        group = model[groupName];
    }
    
    if (!group[jsonKey]) {
        _isPruned = FALSE;
        group[jsonKey] = propertyName;
    }
}

- (void)prune {
    // 1) remove all items from all which have the "links." prefix
    // 2) add items from all to unmapped if not in mapped
    // 3) remove items from unmapped if they are in mapped
    
    NSMutableDictionary *models = self.mappedModels[kModelsKey];
    for (NSString *className in models.allKeys) {
        NSMutableDictionary *model = models[className];
        
        NSMutableDictionary *all = model[kAllKey];
        NSMutableDictionary *mapped = model[kMappedKey];
        NSMutableDictionary *unmapped = model[kUnmappedKey];
        
        NSMutableArray *itemsToRemove = @[].mutableCopy;
        for (NSString *allKey in all.allKeys) {
            if ([allKey hasPrefix:@"links."]) {
                [itemsToRemove addObject:allKey];
            }
            else {
                if (!mapped[allKey]) {
                    unmapped[allKey] = all[allKey];
                }
            }
        }
        [all removeObjectsForKeys:itemsToRemove];
        [itemsToRemove removeAllObjects];
        
        for (NSString *unmappedKey in unmapped.allKeys) {
            if (mapped[unmappedKey]) {
                [itemsToRemove addObject:unmappedKey];
            }
        }
        [unmapped removeObjectsForKeys:itemsToRemove];
    }
    
    _isPruned = TRUE;
}

@end

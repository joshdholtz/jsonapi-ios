//
//  JSONAPIResource.m
//  JSONAPI
//
//  Created by Josh Holtz on 12/24/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "JSONAPIResource.h"

#import "JSONAPIResourceFormatter.h"
#import "JSONAPIResourceLinker.h"
#import "JSONAPIDeveloperAssistant.h"

#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - JSONAPIResource

@interface JSONAPIResource()

@property (nonatomic, strong) NSDictionary *__dictionary;
@property (nonatomic, strong) NSMutableDictionary *__resourceLinks;

@end

@implementation JSONAPIResource

#pragma mark -
#pragma mark - Class Methods

+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked {
    return [JSONAPIResource jsonAPIResources:array withLinked:linked withClass:[self class]];
}

+ (NSArray*)jsonAPIResources:(NSArray*)array withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass {
    if (resourceObjectClass == nil) {
        resourceObjectClass = [self class];
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array) {
        [mutableArray addObject:[[resourceObjectClass alloc] initWithDictionary:dict withLinked:linked]];
    }
    
    return mutableArray;
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked {
    return [JSONAPIResource jsonAPIResource:dictionary withLinked:linked withClass:[self class]];
}

+ (id)jsonAPIResource:(NSDictionary*)dictionary withLinked:(NSDictionary*)linked withClass:(Class)resourceObjectClass {
    if (resourceObjectClass == nil) {
        resourceObjectClass = [self class];
    }
    
    return [[resourceObjectClass alloc] initWithDictionary:dictionary withLinked:linked];
}

#pragma mark -
#pragma mark - Instance Methods

- (id)init {
    self = [super init];
    if (self) {
        self.__resourceLinks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict withLinked:(NSDictionary*)linked {
    self = [self init];
    if (self) {
        [self setWithDictionary:dict];
        [self linkLinks:linked];
        
    }
    return self;
}

- (id)objectForKey:(NSString*)key {
    return [self.__dictionary objectForKey:key];
}

- (id)linkedResourceForKey:(NSString *)key {
    return [self.__resourceLinks objectForKey:key];
}

- (NSDictionary *)mapKeysToProperties {
    return @{};
}

- (void)setWithDictionary:(NSDictionary*)jsonDict {
    self.__dictionary = jsonDict;
    
    // Loops through all keys to map to propertiess
    NSMutableDictionary *map = self.mapKeysToProperties.mutableCopy;
    
    [map addEntriesFromDictionary:@{
                                    @"id" : @"ID",
                                    @"href" : @"href",
                                    @"links" : @"links"
                                    }];
    
    BOOL enabled = [JSONAPIDeveloperAssistant isDevelopmentModeEnabled];
    JSONAPIDeveloperAssistant *da = enabled ? [JSONAPIDeveloperAssistant defaultDeveloperAssistant] : nil;
    NSString *className = enabled ? NSStringFromClass([self class]) : nil;
    
    if (enabled) {
        for (NSString *jsonKey in jsonDict.allKeys) {
            [da addUnmappedJsonKey:jsonKey withPropertyName:@"<null>" forClassName:className];
        }
    }
    
    for (NSString *jsonKey in map.allKeys) {
        
        NSString *propertyName = map[jsonKey];
        [da addJsonKey:jsonKey withPropertyName:propertyName forClassName:className];
        
        // Checks if the key to map is in the dictionary to map
        if (jsonDict[jsonKey] != nil && jsonDict[jsonKey] != [NSNull null]) {
            
            NSRange inflateRange = [propertyName rangeOfString:@"."];
            NSRange formatRange = [propertyName rangeOfString:@":"];
            
            @try {
                if (inflateRange.location != NSNotFound) {
                    // do not map properties with dot syntax (links)
                }
                else if (formatRange.location != NSNotFound) {
                    NSString *formatFunction = [propertyName substringToIndex:formatRange.location];
                    propertyName = [propertyName substringFromIndex:(formatRange.location+1)];
                    id parsedValue = [JSONAPIResourceFormatter performFormatBlock:jsonDict[jsonKey] withName:formatFunction];
                    [self setValue:parsedValue forKey:propertyName];
                    [da addMappedJsonKey:jsonKey withPropertyName:propertyName forClassName:className];
                }
                else {
                    [self setValue:jsonDict[jsonKey] forKey:propertyName];
                    [da addMappedJsonKey:jsonKey withPropertyName:propertyName forClassName:className];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"JSONAPIResource Warning - %@", [exception description]);
            }
        }
    }
}

- (void)linkLinks:(NSDictionary*)linked {
    
    BOOL enabled = [JSONAPIDeveloperAssistant isDevelopmentModeEnabled];
    JSONAPIDeveloperAssistant *da = enabled ? [JSONAPIDeveloperAssistant defaultDeveloperAssistant] : nil;
    NSString *className = enabled ? NSStringFromClass([self class]) : nil;
    
    // Loops through links of resources
    for (NSString *linkTypeUnmapped in self.links.allKeys) {
        
        NSString *linkType = [JSONAPIResourceLinker linkedType:linkTypeUnmapped];
        if (linkType == nil) {
            linkType = linkTypeUnmapped;
        }
        
        // Gets linked objects for the resource
        id linksTo = self.links[linkTypeUnmapped];
        if ([linksTo isKindOfClass:[NSNumber class]] || [linksTo isKindOfClass:[NSString class]]) {
            
            JSONAPIResource *linkedResource = linked[linkType][linksTo];
            
            if (linkedResource != nil) {
                [self.__resourceLinks setObject:linkedResource forKey:linkTypeUnmapped];
            }
            
        } else if ([linksTo isKindOfClass:[NSArray class]]) {
            NSMutableArray *linkedResources = [NSMutableArray array];
            [self.__resourceLinks setObject:linkedResources forKey:linkTypeUnmapped];
            for (id linkedId in linksTo) {
                JSONAPIResource *linkedResource = linked[linkType][linkedId];
                if (linkedResource != nil) {
                    [linkedResources addObject:linkedResource];
                }
            }
            
        }
    }
    
    // Link links for mapped key to properties
    
    NSDictionary *map = self.mapKeysToProperties;
    
    for (NSString *jsonKey in map) {
        if ([jsonKey hasPrefix:@"links."]) {
            
            NSString *propertyName = map[jsonKey];
            NSString *linkedResource = [jsonKey stringByReplacingOccurrencesOfString:@"links." withString:@""];
            
            [da addJsonKey:jsonKey withPropertyName:propertyName forClassName:className];
            
            id resource = [self linkedResourceForKey:linkedResource];
            if (resource != nil) {
                @try {
                    [self setValue:resource forKey:propertyName];
                    [da addMappedJsonKey:linkedResource withPropertyName:propertyName forClassName:className];
                }
                @catch (NSException *exception) {
                    NSLog(@"JSONAPIResource Warning - %@", [exception description]);
                }
            }
            
        }
    }
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    else if ([other isKindOfClass:[JSONAPIResource class]]) {
        JSONAPIResource *otherResource = (JSONAPIResource *)other;
        return [self isEqualToJSONAPIResource:otherResource];
    }
    else {
        return FALSE;
    }
}

- (BOOL)isEqualToJSONAPIResource:(JSONAPIResource *)jsonApiResource {
    if (jsonApiResource) {
        return [self.ID isEqual:jsonApiResource.ID];
    }
    else {
        return FALSE;
    }
}

- (NSUInteger)hash {
    if (self.ID && [self.ID respondsToSelector:@selector(hash)]) {
        return [self.ID hash];
    }
    else {
        return [super hash];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] initWithDictionary:[self.__dictionary copyWithZone:zone] withLinked:nil];
    
    if (copy) {
        // Copy NSObject subclasses
        NSLog(@"__resourceLinks - %@", self.__resourceLinks);
        [copy set__resourceLinks:[self.__resourceLinks copyWithZone:zone]];
        
        // Link links for mapped key to properties
        for (NSString *key in [copy __resourceLinks]) {
            @try {
                [copy setValue:[copy __resourceLinks][key] forKey:key];
            }
            @catch (NSException *exception) {
                NSLog(@"JSONAPIResource Warning - %@", [exception description]);
            }
        }

    }
    
    return copy;
}

#pragma mark - NSCoding

- (NSArray *)propertyKeys {
    NSMutableArray *array = [NSMutableArray array];
    Class class = [self class];
    while (class != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //check if read-only
            BOOL readonly = NO;
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
            {
                readonly = YES;
                
                //see if there is a backing ivar with a KVC-compliant name
                NSRange iVarRange = [encoding rangeOfString:@",V"];
                if (iVarRange.location != NSNotFound)
                {
                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
                    if ([iVarName isEqualToString:key] ||
                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //setValue:forKey: will still work
                        readonly = NO;
                    }
                }
            }
            
            if (!readonly)
            {
                //exclude read-only properties
                [array addObject:key];
            }
        }
        free(properties);
        class = [class superclass];
    }
    return array;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [self init]))
    {
        for (NSString *key in [self propertyKeys])
        {
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [self propertyKeys])
    {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

@end

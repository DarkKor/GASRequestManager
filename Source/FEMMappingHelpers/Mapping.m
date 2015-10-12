//
//  Mapping.m
//  testFem
//
//  Created by Виктор Заикин on 24.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import "Mapping.h"
#import "Relationship.h"

@implementation Mapping

+ (instancetype)createWithMapping:(FEMMapping *)_mapping
                        enityName:(NSString *)entityName {
    Mapping *mapping = [[Mapping alloc] initWithEntityName:entityName];
    
    for (FEMAttribute *attribute in _mapping.attributes) {
        [mapping addAttribute:attribute];
    }
    for (FEMRelationship *relationship in _mapping.relationships) {
        [mapping addRelationship:relationship];
    }
    
    return mapping;
}

+ (instancetype)createWithDict:(NSDictionary *)mappings
                    entityName:(NSString *)entityName {
    Mapping *mapping = [[Mapping alloc] initWithEntityName:entityName];
    
    NSAssert(mappings != nil, @"You should define mapping for entityName");
    
    [mapping addAttributesFromDictionary:mappings];
    
    
    return mapping;
}

+ (instancetype)createWithDict:(NSDictionary *)mappings
                    primaryKey:(NSString *)primaryKey
                    entityName:(NSString *)entityName {
    Mapping *mapping = [Mapping createWithDict:mappings
                                    entityName:entityName];
    if (primaryKey.length > 0)
        [mapping setPrimaryKey:primaryKey];
    
    return mapping;
}

+ (instancetype)createWithDict:(NSDictionary *)mappings
                 relationships:(NSArray *)relationships
                    entityName:(NSString *)entityName {
    Mapping *map = [Mapping createWithDict:mappings
                                entityName:entityName];
    
    for (Relationship *rel in relationships) {
        [map addRelationship:rel];
    }
    
    return map;
}

+ (instancetype)createWithDict:(NSDictionary *)mappings
                    primaryKey:(NSString *)primaryKey
                 relationships:(NSArray *)relationships
                    entityName:(NSString *)entityName {
    Mapping *map = [Mapping createWithDict:mappings
                                primaryKey:primaryKey
                                entityName:entityName];
    
    for (Relationship *rel in relationships) {
        [map addRelationship:rel];
    }
    
    return map;
}

- (void)addRelationships:(NSArray *)relationships {
    for (Relationship *rel in relationships) {
        [self addRelationship:rel];
    }
}

@end

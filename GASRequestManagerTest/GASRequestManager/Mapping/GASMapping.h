//
//  GASMapping.h
//  testFem
//
//  Created by Виктор Заикин on 24.03.15.
//  Copyright (c) 2015 GrowApp Solutions. All rights reserved.
//

#import "FEMManagedObjectMapping.h"
#import <FEMManagedObjectMapping.h>

@interface GASMapping : FEMManagedObjectMapping

+ (instancetype)createWithMapping:(FEMMapping *)_mapping
                        enityName:(NSString *)entityName;

+ (instancetype)createWithDict:(NSDictionary *)mappings
                    entityName:(NSString *)entityName;

+ (instancetype)createWithDict:(NSDictionary *)mappings
                    primaryKey:(NSString *)primaryKey
                    entityName:(NSString *)entityName;

+ (instancetype)createWithDict:(NSDictionary *)mappings
                 relationships:(NSArray *)relationships
                    entityName:(NSString *)entityName;

+ (instancetype)createWithDict:(NSDictionary *)mappings
                    primaryKey:(NSString *)primaryKey
                 relationships:(NSArray *)relationships
                    entityName:(NSString *)entityName;

- (void)addRelationships:(NSArray *)relationships;

@end

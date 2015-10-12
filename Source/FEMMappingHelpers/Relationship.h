//
//  Relationship.h
//  testFem
//
//  Created by Виктор Заикин on 24.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import "FEMRelationship.h"
#import <FEMManagedObjectMapping.h>

@interface Relationship : FEMRelationship

+ (instancetype)createWithMapping:(FEMManagedObjectMapping *)mapping
                      forProperty:(NSString *)forProperty
                          keyPath:(NSString *)keyPath
                           toMany:(BOOL)toMany;

@end

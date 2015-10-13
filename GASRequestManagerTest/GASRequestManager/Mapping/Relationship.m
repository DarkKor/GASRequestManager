//
//  Relationship.m
//  testFem
//
//  Created by Виктор Заикин on 24.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import "Relationship.h"

@implementation Relationship

+ (instancetype)createWithMapping:(FEMManagedObjectMapping *)mapping
                      forProperty:(NSString *)forProperty
                          keyPath:(NSString *)keyPath
                           toMany:(BOOL)toMany {
    Relationship *relationship = [[Relationship alloc] initWithProperty:forProperty
                                                                keyPath:keyPath
                                                                mapping:mapping
                                                       assignmentPolicy:FEMAssignmentPolicyAssign];
    [relationship setToMany:toMany];
    
    return relationship;
}

@end
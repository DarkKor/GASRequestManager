//
//  GASRelationship.m
//  testFem
//
//  Created by Виктор Заикин on 24.03.15.
//  Copyright (c) 2015 GrowApp Solutions. All rights reserved.
//

#import "GASRelationship.h"

@implementation GASRelationship

+ (instancetype)createWithMapping:(FEMManagedObjectMapping *)mapping
                      forProperty:(NSString *)forProperty
                          keyPath:(NSString *)keyPath
                           toMany:(BOOL)toMany {
    GASRelationship *relationship = [[GASRelationship alloc] initWithProperty:forProperty
                                                                keyPath:keyPath
                                                                mapping:mapping
                                                       assignmentPolicy:FEMAssignmentPolicyAssign];
    [relationship setToMany:toMany];
    
    return relationship;
}

@end
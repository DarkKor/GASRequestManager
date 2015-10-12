//
//  FEMManagedObjectDeserializer+DefaultContext.m
//  testFem
//
//  Created by Виктор Заикин on 17.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import "FEMManagedObjectDeserializer+DefaultContext.h"

@implementation FEMManagedObjectDeserializer (DefaultContext)

+ (NSArray *)deserializeCollectionExternalRepresentation:(NSArray *)externalRepresentation
                                            usingMapping:(FEMManagedObjectMapping *)mapping {
    return [self deserializeCollectionExternalRepresentation:externalRepresentation
                                                usingMapping:mapping
                                                     context:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id)deserializeObjectExternalRepresentation:(NSDictionary *)externalRepresentation
                                 usingMapping:(FEMManagedObjectMapping *)mapping {
    return [self deserializeObjectExternalRepresentation:externalRepresentation
                                            usingMapping:mapping
                                                 context:[NSManagedObjectContext MR_contextForCurrentThread]];
}

@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Editor.m instead.

#import "_Editor.h"

const struct EditorAttributes EditorAttributes = {
	.name = @"name",
	.role = @"role",
	.uid = @"uid",
};

const struct EditorRelationships EditorRelationships = {
	.comics = @"comics",
};

@implementation EditorID
@end

@implementation _Editor

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Editor" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Editor";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Editor" inManagedObjectContext:moc_];
}

- (EditorID*)objectID {
	return (EditorID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"uidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic name;

@dynamic role;

@dynamic uid;

- (int32_t)uidValue {
	NSNumber *result = [self uid];
	return [result intValue];
}

- (void)setUidValue:(int32_t)value_ {
	[self setUid:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUidValue {
	NSNumber *result = [self primitiveUid];
	return [result intValue];
}

- (void)setPrimitiveUidValue:(int32_t)value_ {
	[self setPrimitiveUid:[NSNumber numberWithInt:value_]];
}

@dynamic comics;

@end


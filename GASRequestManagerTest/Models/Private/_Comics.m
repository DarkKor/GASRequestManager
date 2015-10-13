// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comics.m instead.

#import "_Comics.h"

const struct ComicsAttributes ComicsAttributes = {
	.caption = @"caption",
	.format = @"format",
	.isbn = @"isbn",
	.pageCount = @"pageCount",
	.thumbUrl = @"thumbUrl",
	.title = @"title",
	.uid = @"uid",
};

const struct ComicsRelationships ComicsRelationships = {
	.editors = @"editors",
};

@implementation ComicsID
@end

@implementation _Comics

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Comics" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Comics";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Comics" inManagedObjectContext:moc_];
}

- (ComicsID*)objectID {
	return (ComicsID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"pageCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pageCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"uidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic caption;

@dynamic format;

@dynamic isbn;

@dynamic pageCount;

- (int16_t)pageCountValue {
	NSNumber *result = [self pageCount];
	return [result shortValue];
}

- (void)setPageCountValue:(int16_t)value_ {
	[self setPageCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePageCountValue {
	NSNumber *result = [self primitivePageCount];
	return [result shortValue];
}

- (void)setPrimitivePageCountValue:(int16_t)value_ {
	[self setPrimitivePageCount:[NSNumber numberWithShort:value_]];
}

@dynamic thumbUrl;

@dynamic title;

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

@dynamic editors;

- (NSMutableSet*)editorsSet {
	[self willAccessValueForKey:@"editors"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"editors"];

	[self didAccessValueForKey:@"editors"];
	return result;
}

@end


// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Editor.h instead.

#import <CoreData/CoreData.h>

extern const struct EditorAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *role;
	__unsafe_unretained NSString *uid;
} EditorAttributes;

extern const struct EditorRelationships {
	__unsafe_unretained NSString *comics;
} EditorRelationships;

@class Comics;

@interface EditorID : NSManagedObjectID {}
@end

@interface _Editor : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EditorID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* role;

//- (BOOL)validateRole:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* uid;

@property (atomic) int32_t uidValue;
- (int32_t)uidValue;
- (void)setUidValue:(int32_t)value_;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Comics *comics;

//- (BOOL)validateComics:(id*)value_ error:(NSError**)error_;

@end

@interface _Editor (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveRole;
- (void)setPrimitiveRole:(NSString*)value;

- (NSNumber*)primitiveUid;
- (void)setPrimitiveUid:(NSNumber*)value;

- (int32_t)primitiveUidValue;
- (void)setPrimitiveUidValue:(int32_t)value_;

- (Comics*)primitiveComics;
- (void)setPrimitiveComics:(Comics*)value;

@end

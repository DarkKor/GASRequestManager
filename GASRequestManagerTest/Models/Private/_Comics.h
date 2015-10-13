// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comics.h instead.

#import <CoreData/CoreData.h>

extern const struct ComicsAttributes {
	__unsafe_unretained NSString *caption;
	__unsafe_unretained NSString *format;
	__unsafe_unretained NSString *isbn;
	__unsafe_unretained NSString *pageCount;
	__unsafe_unretained NSString *thumbUrl;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *uid;
} ComicsAttributes;

extern const struct ComicsRelationships {
	__unsafe_unretained NSString *editors;
} ComicsRelationships;

@class Editor;

@interface ComicsID : NSManagedObjectID {}
@end

@interface _Comics : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ComicsID* objectID;

@property (nonatomic, strong) NSString* caption;

//- (BOOL)validateCaption:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* format;

//- (BOOL)validateFormat:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* isbn;

//- (BOOL)validateIsbn:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* pageCount;

@property (atomic) int16_t pageCountValue;
- (int16_t)pageCountValue;
- (void)setPageCountValue:(int16_t)value_;

//- (BOOL)validatePageCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* thumbUrl;

//- (BOOL)validateThumbUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* uid;

@property (atomic) int32_t uidValue;
- (int32_t)uidValue;
- (void)setUidValue:(int32_t)value_;

//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *editors;

- (NSMutableSet*)editorsSet;

@end

@interface _Comics (EditorsCoreDataGeneratedAccessors)
- (void)addEditors:(NSSet*)value_;
- (void)removeEditors:(NSSet*)value_;
- (void)addEditorsObject:(Editor*)value_;
- (void)removeEditorsObject:(Editor*)value_;

@end

@interface _Comics (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCaption;
- (void)setPrimitiveCaption:(NSString*)value;

- (NSString*)primitiveFormat;
- (void)setPrimitiveFormat:(NSString*)value;

- (NSString*)primitiveIsbn;
- (void)setPrimitiveIsbn:(NSString*)value;

- (NSNumber*)primitivePageCount;
- (void)setPrimitivePageCount:(NSNumber*)value;

- (int16_t)primitivePageCountValue;
- (void)setPrimitivePageCountValue:(int16_t)value_;

- (NSString*)primitiveThumbUrl;
- (void)setPrimitiveThumbUrl:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSNumber*)primitiveUid;
- (void)setPrimitiveUid:(NSNumber*)value;

- (int32_t)primitiveUidValue;
- (void)setPrimitiveUidValue:(int32_t)value_;

- (NSMutableSet*)primitiveEditors;
- (void)setPrimitiveEditors:(NSMutableSet*)value;

@end

///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBPAPERPaperApiBaseError;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `PaperApiBaseError` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBPAPERPaperApiBaseError : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBPAPERPaperApiBaseErrorTag` enum type represents the possible tag
/// states with which the `DBPAPERPaperApiBaseError` union can exist.
typedef NS_ENUM(NSInteger, DBPAPERPaperApiBaseErrorTag) {
  /// Your account does not have permissions to perform this action.
  DBPAPERPaperApiBaseErrorInsufficientPermissions,

  /// (no description).
  DBPAPERPaperApiBaseErrorOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBPAPERPaperApiBaseErrorTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "insufficient_permissions".
///
/// Description of the "insufficient_permissions" tag state: Your account does
/// not have permissions to perform this action.
///
/// @return An initialized instance.
///
- (instancetype)initWithInsufficientPermissions;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value
/// "insufficient_permissions".
///
/// @return Whether the union's current tag state has value
/// "insufficient_permissions".
///
- (BOOL)isInsufficientPermissions;

///
/// Retrieves whether the union's current tag state has value "other".
///
/// @return Whether the union's current tag state has value "other".
///
- (BOOL)isOther;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString *)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBPAPERPaperApiBaseError` union.
///
@interface DBPAPERPaperApiBaseErrorSerializer : NSObject

///
/// Serializes `DBPAPERPaperApiBaseError` instances.
///
/// @param instance An instance of the `DBPAPERPaperApiBaseError` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBPAPERPaperApiBaseError` API object.
///
+ (nullable NSDictionary *)serialize:(DBPAPERPaperApiBaseError *)instance;

///
/// Deserializes `DBPAPERPaperApiBaseError` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBPAPERPaperApiBaseError` API object.
///
/// @return An instantiation of the `DBPAPERPaperApiBaseError` object.
///
+ (DBPAPERPaperApiBaseError *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

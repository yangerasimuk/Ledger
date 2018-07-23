///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGMemberRemoveActionType;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `MemberRemoveActionType` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGMemberRemoveActionType : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMLOGMemberRemoveActionTypeTag` enum type represents the possible
/// tag states with which the `DBTEAMLOGMemberRemoveActionType` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMLOGMemberRemoveActionTypeTag) {
  /// (no description).
  DBTEAMLOGMemberRemoveActionTypeDelete_,

  /// (no description).
  DBTEAMLOGMemberRemoveActionTypeOffboard,

  /// (no description).
  DBTEAMLOGMemberRemoveActionTypeLeave,

  /// (no description).
  DBTEAMLOGMemberRemoveActionTypeOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMLOGMemberRemoveActionTypeTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "delete".
///
/// @return An initialized instance.
///
- (instancetype)initWithDelete_;

///
/// Initializes union class with tag state of "offboard".
///
/// @return An initialized instance.
///
- (instancetype)initWithOffboard;

///
/// Initializes union class with tag state of "leave".
///
/// @return An initialized instance.
///
- (instancetype)initWithLeave;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "delete".
///
/// @return Whether the union's current tag state has value "delete".
///
- (BOOL)isDelete_;

///
/// Retrieves whether the union's current tag state has value "offboard".
///
/// @return Whether the union's current tag state has value "offboard".
///
- (BOOL)isOffboard;

///
/// Retrieves whether the union's current tag state has value "leave".
///
/// @return Whether the union's current tag state has value "leave".
///
- (BOOL)isLeave;

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
/// The serialization class for the `DBTEAMLOGMemberRemoveActionType` union.
///
@interface DBTEAMLOGMemberRemoveActionTypeSerializer : NSObject

///
/// Serializes `DBTEAMLOGMemberRemoveActionType` instances.
///
/// @param instance An instance of the `DBTEAMLOGMemberRemoveActionType` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGMemberRemoveActionType` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGMemberRemoveActionType *)instance;

///
/// Deserializes `DBTEAMLOGMemberRemoveActionType` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGMemberRemoveActionType` API object.
///
/// @return An instantiation of the `DBTEAMLOGMemberRemoveActionType` object.
///
+ (DBTEAMLOGMemberRemoveActionType *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

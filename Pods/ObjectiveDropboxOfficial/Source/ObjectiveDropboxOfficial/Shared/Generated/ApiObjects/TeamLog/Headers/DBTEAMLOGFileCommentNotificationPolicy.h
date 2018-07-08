///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGFileCommentNotificationPolicy;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `FileCommentNotificationPolicy` union.
///
/// Enable or disable file comments notifications
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGFileCommentNotificationPolicy : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMLOGFileCommentNotificationPolicyTag` enum type represents the
/// possible tag states with which the `DBTEAMLOGFileCommentNotificationPolicy`
/// union can exist.
typedef NS_ENUM(NSInteger, DBTEAMLOGFileCommentNotificationPolicyTag) {
  /// (no description).
  DBTEAMLOGFileCommentNotificationPolicyDisabled,

  /// (no description).
  DBTEAMLOGFileCommentNotificationPolicyEnabled,

  /// (no description).
  DBTEAMLOGFileCommentNotificationPolicyOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMLOGFileCommentNotificationPolicyTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "disabled".
///
/// @return An initialized instance.
///
- (instancetype)initWithDisabled;

///
/// Initializes union class with tag state of "enabled".
///
/// @return An initialized instance.
///
- (instancetype)initWithEnabled;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "disabled".
///
/// @return Whether the union's current tag state has value "disabled".
///
- (BOOL)isDisabled;

///
/// Retrieves whether the union's current tag state has value "enabled".
///
/// @return Whether the union's current tag state has value "enabled".
///
- (BOOL)isEnabled;

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
/// The serialization class for the `DBTEAMLOGFileCommentNotificationPolicy`
/// union.
///
@interface DBTEAMLOGFileCommentNotificationPolicySerializer : NSObject

///
/// Serializes `DBTEAMLOGFileCommentNotificationPolicy` instances.
///
/// @param instance An instance of the `DBTEAMLOGFileCommentNotificationPolicy`
/// API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGFileCommentNotificationPolicy` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGFileCommentNotificationPolicy *)instance;

///
/// Deserializes `DBTEAMLOGFileCommentNotificationPolicy` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGFileCommentNotificationPolicy` API object.
///
/// @return An instantiation of the `DBTEAMLOGFileCommentNotificationPolicy`
/// object.
///
+ (DBTEAMLOGFileCommentNotificationPolicy *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

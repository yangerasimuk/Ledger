///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGSmartSyncPolicy;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `SmartSyncPolicy` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGSmartSyncPolicy : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMLOGSmartSyncPolicyTag` enum type represents the possible tag
/// states with which the `DBTEAMLOGSmartSyncPolicy` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMLOGSmartSyncPolicyTag) {
  /// (no description).
  DBTEAMLOGSmartSyncPolicyLocalOnly,

  /// (no description).
  DBTEAMLOGSmartSyncPolicySynced,

  /// (no description).
  DBTEAMLOGSmartSyncPolicyOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMLOGSmartSyncPolicyTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "local_only".
///
/// @return An initialized instance.
///
- (instancetype)initWithLocalOnly;

///
/// Initializes union class with tag state of "synced".
///
/// @return An initialized instance.
///
- (instancetype)initWithSynced;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "local_only".
///
/// @return Whether the union's current tag state has value "local_only".
///
- (BOOL)isLocalOnly;

///
/// Retrieves whether the union's current tag state has value "synced".
///
/// @return Whether the union's current tag state has value "synced".
///
- (BOOL)isSynced;

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
/// The serialization class for the `DBTEAMLOGSmartSyncPolicy` union.
///
@interface DBTEAMLOGSmartSyncPolicySerializer : NSObject

///
/// Serializes `DBTEAMLOGSmartSyncPolicy` instances.
///
/// @param instance An instance of the `DBTEAMLOGSmartSyncPolicy` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGSmartSyncPolicy` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGSmartSyncPolicy *)instance;

///
/// Deserializes `DBTEAMLOGSmartSyncPolicy` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGSmartSyncPolicy` API object.
///
/// @return An instantiation of the `DBTEAMLOGSmartSyncPolicy` object.
///
+ (DBTEAMLOGSmartSyncPolicy *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

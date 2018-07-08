///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGSharedFolderMemberPolicy;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `SharedFolderMemberPolicy` union.
///
/// Policy for controlling who can become a member of a shared folder
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGSharedFolderMemberPolicy : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMLOGSharedFolderMemberPolicyTag` enum type represents the possible
/// tag states with which the `DBTEAMLOGSharedFolderMemberPolicy` union can
/// exist.
typedef NS_ENUM(NSInteger, DBTEAMLOGSharedFolderMemberPolicyTag) {
  /// (no description).
  DBTEAMLOGSharedFolderMemberPolicyTeamOnly,

  /// (no description).
  DBTEAMLOGSharedFolderMemberPolicyAnyone,

  /// (no description).
  DBTEAMLOGSharedFolderMemberPolicyOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMLOGSharedFolderMemberPolicyTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "team_only".
///
/// @return An initialized instance.
///
- (instancetype)initWithTeamOnly;

///
/// Initializes union class with tag state of "anyone".
///
/// @return An initialized instance.
///
- (instancetype)initWithAnyone;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "team_only".
///
/// @return Whether the union's current tag state has value "team_only".
///
- (BOOL)isTeamOnly;

///
/// Retrieves whether the union's current tag state has value "anyone".
///
/// @return Whether the union's current tag state has value "anyone".
///
- (BOOL)isAnyone;

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
/// The serialization class for the `DBTEAMLOGSharedFolderMemberPolicy` union.
///
@interface DBTEAMLOGSharedFolderMemberPolicySerializer : NSObject

///
/// Serializes `DBTEAMLOGSharedFolderMemberPolicy` instances.
///
/// @param instance An instance of the `DBTEAMLOGSharedFolderMemberPolicy` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGSharedFolderMemberPolicy` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGSharedFolderMemberPolicy *)instance;

///
/// Deserializes `DBTEAMLOGSharedFolderMemberPolicy` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGSharedFolderMemberPolicy` API object.
///
/// @return An instantiation of the `DBTEAMLOGSharedFolderMemberPolicy` object.
///
+ (DBTEAMLOGSharedFolderMemberPolicy *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

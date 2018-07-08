///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMAdminTier;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `AdminTier` union.
///
/// Describes which team-related admin permissions a user has.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMAdminTier : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMAdminTierTag` enum type represents the possible tag states with
/// which the `DBTEAMAdminTier` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMAdminTierTag) {
  /// User is an administrator of the team - has all permissions.
  DBTEAMAdminTierTeamAdmin,

  /// User can do most user provisioning, de-provisioning and management.
  DBTEAMAdminTierUserManagementAdmin,

  /// User can do a limited set of common support tasks for existing users.
  DBTEAMAdminTierSupportAdmin,

  /// User is not an admin of the team.
  DBTEAMAdminTierMemberOnly,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMAdminTierTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "team_admin".
///
/// Description of the "team_admin" tag state: User is an administrator of the
/// team - has all permissions.
///
/// @return An initialized instance.
///
- (instancetype)initWithTeamAdmin;

///
/// Initializes union class with tag state of "user_management_admin".
///
/// Description of the "user_management_admin" tag state: User can do most user
/// provisioning, de-provisioning and management.
///
/// @return An initialized instance.
///
- (instancetype)initWithUserManagementAdmin;

///
/// Initializes union class with tag state of "support_admin".
///
/// Description of the "support_admin" tag state: User can do a limited set of
/// common support tasks for existing users.
///
/// @return An initialized instance.
///
- (instancetype)initWithSupportAdmin;

///
/// Initializes union class with tag state of "member_only".
///
/// Description of the "member_only" tag state: User is not an admin of the
/// team.
///
/// @return An initialized instance.
///
- (instancetype)initWithMemberOnly;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "team_admin".
///
/// @return Whether the union's current tag state has value "team_admin".
///
- (BOOL)isTeamAdmin;

///
/// Retrieves whether the union's current tag state has value
/// "user_management_admin".
///
/// @return Whether the union's current tag state has value
/// "user_management_admin".
///
- (BOOL)isUserManagementAdmin;

///
/// Retrieves whether the union's current tag state has value "support_admin".
///
/// @return Whether the union's current tag state has value "support_admin".
///
- (BOOL)isSupportAdmin;

///
/// Retrieves whether the union's current tag state has value "member_only".
///
/// @return Whether the union's current tag state has value "member_only".
///
- (BOOL)isMemberOnly;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString *)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMAdminTier` union.
///
@interface DBTEAMAdminTierSerializer : NSObject

///
/// Serializes `DBTEAMAdminTier` instances.
///
/// @param instance An instance of the `DBTEAMAdminTier` API object.
///
/// @return A json-compatible dictionary representation of the `DBTEAMAdminTier`
/// API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMAdminTier *)instance;

///
/// Deserializes `DBTEAMAdminTier` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMAdminTier` API object.
///
/// @return An instantiation of the `DBTEAMAdminTier` object.
///
+ (DBTEAMAdminTier *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

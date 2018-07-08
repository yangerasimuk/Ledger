///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMAdminTier;
@class DBTEAMTeamMemberInfo;
@class DBTEAMTeamMemberProfile;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `TeamMemberInfo` struct.
///
/// Information about a team member.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMTeamMemberInfo : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Profile of a user as a member of a team.
@property (nonatomic, readonly) DBTEAMTeamMemberProfile *profile;

/// The user's role in the team.
@property (nonatomic, readonly) DBTEAMAdminTier *role;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param profile Profile of a user as a member of a team.
/// @param role The user's role in the team.
///
/// @return An initialized instance.
///
- (instancetype)initWithProfile:(DBTEAMTeamMemberProfile *)profile role:(DBTEAMAdminTier *)role;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `TeamMemberInfo` struct.
///
@interface DBTEAMTeamMemberInfoSerializer : NSObject

///
/// Serializes `DBTEAMTeamMemberInfo` instances.
///
/// @param instance An instance of the `DBTEAMTeamMemberInfo` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMTeamMemberInfo` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMTeamMemberInfo *)instance;

///
/// Deserializes `DBTEAMTeamMemberInfo` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMTeamMemberInfo` API object.
///
/// @return An instantiation of the `DBTEAMTeamMemberInfo` object.
///
+ (DBTEAMTeamMemberInfo *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
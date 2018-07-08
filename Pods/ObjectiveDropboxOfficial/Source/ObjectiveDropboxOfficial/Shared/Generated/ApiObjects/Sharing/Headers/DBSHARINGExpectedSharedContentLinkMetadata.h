///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSHARINGSharedContentLinkMetadataBase.h"
#import "DBSerializableProtocol.h"

@class DBSHARINGAccessLevel;
@class DBSHARINGAudienceRestrictingSharedFolder;
@class DBSHARINGExpectedSharedContentLinkMetadata;
@class DBSHARINGLinkAudience;
@class DBSHARINGLinkPermission;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `ExpectedSharedContentLinkMetadata` struct.
///
/// The expected metadata of a shared link for a file or folder when a link is
/// first created for the content. Absent if the link already exists.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGExpectedSharedContentLinkMetadata
    : DBSHARINGSharedContentLinkMetadataBase <DBSerializable, NSCopying>

#pragma mark - Instance fields

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param audienceOptions The audience options that are available for the
/// content. Some audience options may be unavailable. For example, team_only
/// may be unavailable if the content is not owned by a user on a team. The
/// 'default' audience option is always available if the user can modify link
/// settings.
/// @param currentAudience The current audience of the link.
/// @param linkPermissions A list of permissions for actions you can perform on
/// the link.
/// @param passwordProtected Whether the link is protected by a password.
/// @param accessLevel The access level on the link for this file.
/// @param audienceRestrictingSharedFolder The shared folder that prevents the
/// link audience for this link from being more restrictive.
/// @param expiry Whether the link has an expiry set on it. A link with an
/// expiry will have its  audience changed to members when the expiry is
/// reached.
///
/// @return An initialized instance.
///
- (instancetype)initWithAudienceOptions:(NSArray<DBSHARINGLinkAudience *> *)audienceOptions
                        currentAudience:(DBSHARINGLinkAudience *)currentAudience
                        linkPermissions:(NSArray<DBSHARINGLinkPermission *> *)linkPermissions
                      passwordProtected:(NSNumber *)passwordProtected
                            accessLevel:(nullable DBSHARINGAccessLevel *)accessLevel
        audienceRestrictingSharedFolder:
            (nullable DBSHARINGAudienceRestrictingSharedFolder *)audienceRestrictingSharedFolder
                                 expiry:(nullable NSDate *)expiry;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param audienceOptions The audience options that are available for the
/// content. Some audience options may be unavailable. For example, team_only
/// may be unavailable if the content is not owned by a user on a team. The
/// 'default' audience option is always available if the user can modify link
/// settings.
/// @param currentAudience The current audience of the link.
/// @param linkPermissions A list of permissions for actions you can perform on
/// the link.
/// @param passwordProtected Whether the link is protected by a password.
///
/// @return An initialized instance.
///
- (instancetype)initWithAudienceOptions:(NSArray<DBSHARINGLinkAudience *> *)audienceOptions
                        currentAudience:(DBSHARINGLinkAudience *)currentAudience
                        linkPermissions:(NSArray<DBSHARINGLinkPermission *> *)linkPermissions
                      passwordProtected:(NSNumber *)passwordProtected;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `ExpectedSharedContentLinkMetadata` struct.
///
@interface DBSHARINGExpectedSharedContentLinkMetadataSerializer : NSObject

///
/// Serializes `DBSHARINGExpectedSharedContentLinkMetadata` instances.
///
/// @param instance An instance of the
/// `DBSHARINGExpectedSharedContentLinkMetadata` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGExpectedSharedContentLinkMetadata` API object.
///
+ (nullable NSDictionary *)serialize:(DBSHARINGExpectedSharedContentLinkMetadata *)instance;

///
/// Deserializes `DBSHARINGExpectedSharedContentLinkMetadata` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGExpectedSharedContentLinkMetadata` API object.
///
/// @return An instantiation of the `DBSHARINGExpectedSharedContentLinkMetadata`
/// object.
///
+ (DBSHARINGExpectedSharedContentLinkMetadata *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

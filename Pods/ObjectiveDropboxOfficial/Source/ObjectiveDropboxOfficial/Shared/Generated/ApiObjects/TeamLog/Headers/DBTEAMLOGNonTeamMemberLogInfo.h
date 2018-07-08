///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"
#import "DBTEAMLOGUserLogInfo.h"

@class DBTEAMLOGNonTeamMemberLogInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `NonTeamMemberLogInfo` struct.
///
/// Non team member's logged information.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGNonTeamMemberLogInfo : DBTEAMLOGUserLogInfo <DBSerializable, NSCopying>

#pragma mark - Instance fields

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param accountId User unique ID. Might be missing due to historical data
/// gap.
/// @param displayName User display name. Might be missing due to historical
/// data gap.
/// @param email User email address. Might be missing due to historical data
/// gap.
///
/// @return An initialized instance.
///
- (instancetype)initWithAccountId:(nullable NSString *)accountId
                      displayName:(nullable NSString *)displayName
                            email:(nullable NSString *)email;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
///
/// @return An initialized instance.
///
- (instancetype)initDefault;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `NonTeamMemberLogInfo` struct.
///
@interface DBTEAMLOGNonTeamMemberLogInfoSerializer : NSObject

///
/// Serializes `DBTEAMLOGNonTeamMemberLogInfo` instances.
///
/// @param instance An instance of the `DBTEAMLOGNonTeamMemberLogInfo` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGNonTeamMemberLogInfo` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGNonTeamMemberLogInfo *)instance;

///
/// Deserializes `DBTEAMLOGNonTeamMemberLogInfo` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGNonTeamMemberLogInfo` API object.
///
/// @return An instantiation of the `DBTEAMLOGNonTeamMemberLogInfo` object.
///
+ (DBTEAMLOGNonTeamMemberLogInfo *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

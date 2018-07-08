///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMMembersGetInfoArgs;
@class DBTEAMUserSelectorArg;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `MembersGetInfoArgs` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMMembersGetInfoArgs : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// List of team members.
@property (nonatomic, readonly) NSArray<DBTEAMUserSelectorArg *> *members;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param members List of team members.
///
/// @return An initialized instance.
///
- (instancetype)initWithMembers:(NSArray<DBTEAMUserSelectorArg *> *)members;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `MembersGetInfoArgs` struct.
///
@interface DBTEAMMembersGetInfoArgsSerializer : NSObject

///
/// Serializes `DBTEAMMembersGetInfoArgs` instances.
///
/// @param instance An instance of the `DBTEAMMembersGetInfoArgs` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMMembersGetInfoArgs` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMMembersGetInfoArgs *)instance;

///
/// Deserializes `DBTEAMMembersGetInfoArgs` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMMembersGetInfoArgs` API object.
///
/// @return An instantiation of the `DBTEAMMembersGetInfoArgs` object.
///
+ (DBTEAMMembersGetInfoArgs *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

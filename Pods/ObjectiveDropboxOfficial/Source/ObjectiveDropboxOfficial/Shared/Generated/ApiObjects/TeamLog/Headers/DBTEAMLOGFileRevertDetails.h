///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGFileRevertDetails;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `FileRevertDetails` struct.
///
/// Reverted files to a previous version.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGFileRevertDetails : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @return An initialized instance.
///
- (instancetype)initDefault;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `FileRevertDetails` struct.
///
@interface DBTEAMLOGFileRevertDetailsSerializer : NSObject

///
/// Serializes `DBTEAMLOGFileRevertDetails` instances.
///
/// @param instance An instance of the `DBTEAMLOGFileRevertDetails` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGFileRevertDetails` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGFileRevertDetails *)instance;

///
/// Deserializes `DBTEAMLOGFileRevertDetails` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGFileRevertDetails` API object.
///
/// @return An instantiation of the `DBTEAMLOGFileRevertDetails` object.
///
+ (DBTEAMLOGFileRevertDetails *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

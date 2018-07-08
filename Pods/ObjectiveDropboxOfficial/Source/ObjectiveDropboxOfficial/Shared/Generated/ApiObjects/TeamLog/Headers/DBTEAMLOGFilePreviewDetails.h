///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGFilePreviewDetails;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `FilePreviewDetails` struct.
///
/// Previewed files and/or folders.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGFilePreviewDetails : NSObject <DBSerializable, NSCopying>

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
/// The serialization class for the `FilePreviewDetails` struct.
///
@interface DBTEAMLOGFilePreviewDetailsSerializer : NSObject

///
/// Serializes `DBTEAMLOGFilePreviewDetails` instances.
///
/// @param instance An instance of the `DBTEAMLOGFilePreviewDetails` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGFilePreviewDetails` API object.
///
+ (nullable NSDictionary *)serialize:(DBTEAMLOGFilePreviewDetails *)instance;

///
/// Deserializes `DBTEAMLOGFilePreviewDetails` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGFilePreviewDetails` API object.
///
/// @return An instantiation of the `DBTEAMLOGFilePreviewDetails` object.
///
+ (DBTEAMLOGFilePreviewDetails *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

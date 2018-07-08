///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBUSERSIndividualSpaceAllocation;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `IndividualSpaceAllocation` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBUSERSIndividualSpaceAllocation : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The total space allocated to the user's account (bytes).
@property (nonatomic, readonly) NSNumber *allocated;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param allocated The total space allocated to the user's account (bytes).
///
/// @return An initialized instance.
///
- (instancetype)initWithAllocated:(NSNumber *)allocated;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `IndividualSpaceAllocation` struct.
///
@interface DBUSERSIndividualSpaceAllocationSerializer : NSObject

///
/// Serializes `DBUSERSIndividualSpaceAllocation` instances.
///
/// @param instance An instance of the `DBUSERSIndividualSpaceAllocation` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBUSERSIndividualSpaceAllocation` API object.
///
+ (nullable NSDictionary *)serialize:(DBUSERSIndividualSpaceAllocation *)instance;

///
/// Deserializes `DBUSERSIndividualSpaceAllocation` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBUSERSIndividualSpaceAllocation` API object.
///
/// @return An instantiation of the `DBUSERSIndividualSpaceAllocation` object.
///
+ (DBUSERSIndividualSpaceAllocation *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

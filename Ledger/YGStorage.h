//
//  YGStorage.h
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YGBackup;

typedef NS_ENUM(NSInteger, YGStorageType){
    YGStorageTypeLocal,
    YGStorageTypeICloud,
    YGStorageTypeDropbox
};

@protocol YGStoraging <NSObject>
- (NSString *)backupDb;
- (void)restoreDb:(YGBackup *)backup;
- (YGStorageType)type;
- (NSArray <YGBackup *>*)backups;
@end

@interface YGStorage : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) YGStorageType type;


/// base init
- (instancetype)initWithName:(NSString *)name type:(YGStorageType)type;

/// fabric method for creation any storage
+ (id<YGStoraging>)storageWithName:(NSString *)name;

@end

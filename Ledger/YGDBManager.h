//
//  YGDBManager.h
//  Ledger
//
//  Created by Ян on 06/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGStorage.h"

@interface YGDBManager : NSObject

@property (copy, nonatomic) NSMutableArray <id<YGStoraging>> *storages;

+ (YGDBManager *)sharedInstance;

- (instancetype)init;

- (id<YGStoraging>)storageByType:(YGStorageType)type;

- (BOOL)isDbExists;
- (void)makeNewDb;
- (NSString *)lastOperation;

- (NSString *)databaseFullName;

@end

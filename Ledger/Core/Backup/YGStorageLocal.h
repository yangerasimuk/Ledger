//
//  YGStorageLocal.h
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGStorage.h"

@class YGBackup;

@interface YGStorageLocal : YGStorage <YGStoraging>

- (instancetype)init;

- (NSArray <YGBackup *>*)backups;
- (NSString *)backupDb;
- (void)restoreDb:(YGBackup *)backup;

@end

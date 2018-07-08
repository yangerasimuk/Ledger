//
//  YYGStorageLocal.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorage.h"

@interface YYGStorageLocal : YYGStorage <YYGStoraging>

- (BOOL)isNeedLoadView;
- (void)checkBackupExists;
- (NSDictionary *)backupInfo;
- (void)backup:(NSString *)fileName;
- (void)restore;

@end

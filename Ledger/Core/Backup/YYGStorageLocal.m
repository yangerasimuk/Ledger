//
//  YYGStorageLocal.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorageLocal.h"

@implementation YYGStorageLocal

- (BOOL)isNeedLoadView {
    return NO;
}

- (void)checkBackupExists {
    @throw [NSException exceptionWithName:@"Method not realized" reason:@"YYGStorageLocal checkBackup is not realized." userInfo:nil];
}

- (NSDictionary *)backupInfo {
    @throw [NSException exceptionWithName:@"Method not realized" reason:@"YYGStorageLocal backupInfo is not realized." userInfo:nil];
}

- (void)backup:(NSString *)fileName {
        @throw [NSException exceptionWithName:@"Method not realized" reason:@"YYGStorageLocal backup is not realized." userInfo:nil];
}

- (void)restore {
    @throw [NSException exceptionWithName:@"Method not realized" reason:@"YYGStorageLocal restore is not reaized." userInfo:nil];
}

@end

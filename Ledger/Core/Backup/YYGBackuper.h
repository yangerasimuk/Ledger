//
//  YYGBackuper.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YYGBackuperOwner
- (void)notifyMessage:(NSString *)message;
- (void)notifyBackupDbSuccess;
- (void)notifyBackupDbError:(NSString *)message;
@end

@interface YYGBackuper : NSObject

/// Delegate-owner of backuper
@property (weak, nonatomic) id<YYGBackuperOwner> owner;

/// File name of backuped database
@property (strong, nonatomic) NSString *fileName;

- (void)backupDb;

@end

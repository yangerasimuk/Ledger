//
//  YYGBackuper.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGBackuper.h"
#import "YGSQLite.h"
#import "YGDBManager.h"
#import "YYGLedgerDefine.h"
#import "YGFile.h"
#import "YGTools.h"
#import "YGConfig.h"

@implementation YYGBackuper

- (void)backupDb{
    
    [self.owner notifyMessage:NSLocalizedString(@"BACKUPER_MAKE_SNAPSHOT_MESSAGE", @"Make snapshot of work db...")];
    
    @try {
        
        // copy db and get name of new backup
        _fileName = [self snapshotWorkDb];
        
        [self saveInfoForBackup:_fileName];
        
        if ([self isBackupBundleValid:_fileName]){
            [_owner notifyBackupDbSuccess];
        } else {
            [_owner notifyBackupDbError:NSLocalizedString(@"BACKUPER_BUNDLE_IS_NOT_VALID", @"Backup bundle is not valid.")];
        }
    }
    @catch(NSException *ex) {
        [_owner notifyBackupDbError:[ex description]];
    }
}

- (NSString *)snapshotWorkDb {
    
    // work db full name
    NSString *workFullName = [YGSQLite databaseFullName];
    
    //new name
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormatForBackupName];
    NSString *newName = [NSString stringWithFormat:@"%@.ledger.db.sqlite", [formatter stringFromDate:date]];
    
    // new full path
    NSString *newFullName = [NSTemporaryDirectory() stringByAppendingPathComponent:newName];
    //NSString *newFullName = [[YGTools documentsDirectoryPath] stringByAppendingPathComponent:newName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if(![fm copyItemAtPath:workFullName toPath:newFullName error:&error]){
        NSLog(@"Fail to copy work db to backup");
        NSLog(@"Error: %@", [error description]);
    }
    
    return [newFullName copy];
}

- (void) saveInfoForBackup:(NSString *)fullPath {
    
    @try {
        // save info about new backup in application config file
        // 1. get size
        YGFile *backupFile = [[YGFile alloc] initWithPathFull:fullPath];
        NSString *backupDBSizeString = [YGTools humanViewStringForByteSize:backupFile.size];
        
        // 2. get backup date string
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:kDateTimeFormat];
        
        NSString *backupDateString = [formatter stringFromDate:date];
        
        // 3. get last operation date string
        YGDBManager *dm = [YGDBManager sharedInstance];
        NSString *lastOperationString = [dm lastOperation];
        
        if(!lastOperationString)
            lastOperationString = @"";
        
        // 4. save backup info in app config
        YGConfig *config = [YGTools config];
        
        NSDictionary *dic = @{@"BackupFileName":[fullPath lastPathComponent], @"LastOperation":lastOperationString, @"BackupDate":backupDateString, @"BackupDBSize":backupDBSizeString};
        
        NSArray *backups = @[dic];
        
        // new !
        [config setValue:backups forKey:@"LocalBackup"];
        
        // new !
        if (![dic writeToFile:[NSString stringWithFormat:@"%@.xml", fullPath] atomically:YES]){
            // Error
            @throw [NSException exceptionWithName:@"Error write to info file" reason:@"YYGBackuper.saveInfoForBackup. Fail to write to backup, info, xml file." userInfo:nil];
        }

    }
    @catch(NSException *ex) {
        @throw ex;
    }
}

- (BOOL)isBackupBundleValid:(NSString *)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check sqlite data file exist
    if (![fileManager fileExistsAtPath:fileName]) {
        NSLog(@"YYGBackuper. Error: sqlite data file NOT exists.");
        return NO;
    }
    
    //Check info xml file exit
    NSString *infoFileName = [fileName stringByAppendingString:@".xml"];
    if (![fileManager fileExistsAtPath:infoFileName]) {
        NSLog(@"YYGBackuper. Error: info xml file NOT exists.");
        return NO;
    }
    
    return YES;
}

@end

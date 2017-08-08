//
//  YGStorageLocal.m
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGStorageLocal.h"
#import <YGFileSystem.h>
#import "YGTools.h"
#import "YGBackup.h"
#import "YGSQLite.h"
#import "YGDBManager.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"

@interface YGStorageLocal ()

- (void) saveInfoAboutBackup:(NSString *)fullPath;
- (void)copyToWorkDbBackup:(YGBackup *)backup;
- (NSString *)copyWorkDbToBackup;

@end

@implementation YGStorageLocal

- (instancetype)init{
    self = [super initWithName:@"STORAGE_LOCAL" type:YGStorageTypeLocal];
    if(self){
        ;
    }
    return self;
}

- (NSArray <YGBackup *>*)backups {
    
    NSString *path = [YGTools documentsDirectoryPath];
    
    YGDirectory *documentDirectory = [[YGDirectory alloc] initWithPathFull:path];
    
    YGSearchRuleByType *rule1 = [[YGSearchRuleByType alloc] initWithFileSystemObjectType:YGFileSystemObjectTypeFile];
    
    YGSearchRuleNameMinLength *rule2 = [[YGSearchRuleNameMinLength alloc] initWithNameMinLength:30];
    
    YGSearchRuleNameIsRegex *rule3 = [[YGSearchRuleNameIsRegex alloc] initWithPattern:@"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite$"];
    
    NSArray <YGConfirmingRule> *rules = (NSArray <YGConfirmingRule> *)[NSArray arrayWithObjects:rule1, rule2, rule3, nil];
    
    YGSearchPattern *pattern = [[YGSearchPattern alloc] initWithSearchRules:rules];
    
    YGFileSystemEnumerator *en = [[YGFileSystemEnumerator alloc] initWithDirectory:documentDirectory searchPattern:pattern];
    
    NSArray *objects = [en objects];
    
    NSMutableArray *backups = [[NSMutableArray alloc] init];
    
    for(YGFileSystemObject *obj in objects){
        
        YGBackup *backup = [[YGBackup alloc] initWithName:obj.name storage:self];
        [backups addObject:backup];
    }
    
    if([backups count] > 0)
        return [backups mutableCopy];
    else
        return nil;
}


/**
 Copy current work db file to backup with timestamped name.
 
 @return Name of new backup (full path).
 */
- (NSString *)copyWorkDbToBackup {
    
    // work db full name
    NSString *workFullName = [YGSQLite databaseFullName];
    
    //new name
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormatForBackupName];
    NSString *newName = [NSString stringWithFormat:@"%@.ledger.db.sqlite", [formatter stringFromDate:date]];
    
    // new full path
    NSString *newFullName = [[YGTools documentsDirectoryPath] stringByAppendingPathComponent:newName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if(![fm copyItemAtPath:workFullName toPath:newFullName error:&error]){
        NSLog(@"Fail to copy work db to backup");
        NSLog(@"Error: %@", [error description]);
    }

    return [newFullName copy];
    
}


/**
 Copy given backup to work db.
 
 @param backup Backup for restore to work db.
 
 @warning Work db must be backup befor this operation.
 */
- (void)copyToWorkDbBackup:(YGBackup *)backup {
    
    // backup full path
    NSString *backupFullName = [[YGTools documentsDirectoryPath] stringByAppendingPathComponent:backup.name];
    
    // work db full name
    NSString *workFullName = [YGSQLite databaseFullName];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    if(![fm removeItemAtPath:workFullName error:&error]){
        NSLog(@"Fail to remove work db");
        NSLog(@"Error: %@", [error description]);
    }
    
    if(![fm copyItemAtPath:backupFullName toPath:workFullName error:&error]){
        NSLog(@"Fail to restore backup to work db");
        NSLog(@"Error: %@", [error description]);
    }
}


/**
 Backup current work db to backup, delete old backups and save info about new backup to app config file.
 
 @return New backup file name (full path).
 */
- (NSString *)backupDb {
    
    // get list of all current backups, for deletion after copy db
    NSArray *backups = [self backups];
    
    // copy db and get name of new backup
    NSString *newBackupFullName = [self copyWorkDbToBackup];
    
    [self saveInfoAboutBackup:newBackupFullName];
    
    [self removeOldBackups:backups];
    
    return newBackupFullName;
}

/**
 Save information about backup to application config file.
 
 @param fullPath Full name of backup file.
 */
- (void) saveInfoAboutBackup:(NSString *)fullPath {
    
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
    [dic writeToFile:[NSString stringWithFormat:@"%@.xml", fullPath] atomically:YES];

}

/**
 Remove all given backup files.
 
 @warning Array backups can not contain new backup file.
 
 @param backups Array of backup files to delete.
 */
- (void)removeOldBackups:(NSArray <YGBackup *>*)backups {
    
    NSString *documentsDirectory = [YGTools documentsDirectoryPath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // delete all old backups
    for (YGBackup *backup in backups){
        NSString *oldBackupFullName = [documentsDirectory stringByAppendingPathComponent:backup.name];
        
        if(![fm removeItemAtPath:oldBackupFullName error:&error]){
            NSLog(@"Fail to remove old backup");
            NSLog(@"Error: %@", [error description]);
        }
        
        // if exist backup info xml file - delete too
        NSString *oldBackupInfoFullName = [oldBackupFullName stringByAppendingString:@".xml"];
        
        if([fm fileExistsAtPath:oldBackupInfoFullName]){
            if(![fm removeItemAtPath:oldBackupInfoFullName error:&error]){
                NSLog(@"Fail to remove old backup info file");
                NSLog(@"Error: %@", [error description]);
            }
        }
    }
}

/**
 Restore given backup file to work db, save info about new backup in app config file and remove all old backups.
 
 @warning If call this method very often may be problem this "recurce of dirs", test it!
 
 @param backup Backup file to restore in work db.
 */
- (void)restoreDb:(YGBackup *)backup {
    
    // 1. get list of old backups for delete
    //NSArray <YGBackup *>*backups = [self backups];
    
    // 2. Copy current db to new backup
    //NSString *newBackupFileFullName = [self copyWorkDbToBackup];
        
    // 3. Save info about backup to app config file
    //[self saveInfoAboutBackup:newBackupFileFullName];
    
    // 4. Copy from given backup to work db
    [self copyToWorkDbBackup:backup];
    
    // 5. remove old backups
    //[self removeOldBackups:backups];
    
}

@end

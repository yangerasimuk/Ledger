//
//  YYGUpdater+Versions.m
//  Ledger
//
//  Created by Ян on 27.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGUpdater+Versions.h"
#import "YGSQLite.h"
#import <sqlite3.h>
#import "YYGLedgerDefine.h"
#import "YGTools.h"

@implementation YYGUpdater (Versions)

/**
 Update to version 1.2(5).
 [+] In table entity add columns: counterparty_id and counterparty_type_id.
 [+] Database scheme version set to 2.
 
 @return Success or fail.
 */
- (NSNumber *)updateToVersionMajor1Minor2Build5 {
#ifdef DEBUG
    NSLog(@"Update to version 1.2(5)...");
#endif
    
    // Check update needs
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    if([sqlite hasColumn:@"counterparty_id" inTable:@"entity"]
       && [sqlite hasColumn:@"counterparty_type_id" inTable:@"entity"])
        return @YES;
    
    // Prepare updade
    BOOL updateResult = NO;
    NSInteger result = NSNotFound;
    sqlite3 *db;
    NSString *sql;
    char *error = 0;
    
    @try {
        // Open db
        NSString *databaseFullName = [[YGTools documentsDirectoryPath] stringByAppendingPathComponent:kDatabaseName];
        NSInteger result = NSNotFound;
        result = sqlite3_open([databaseFullName UTF8String], &db);
        if(result != SQLITE_OK)
            @throw [NSException exceptionWithName:@"Fail to open db."
                                           reason:[NSString stringWithFormat:@"Result: %ld", result]
                                         userInfo:nil];
        
        // BEGIN TRANSACTION;
        sql = @"BEGIN TRANSACTION";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSString *errMsg = nil;
            if(error){
                errMsg = [NSString stringWithUTF8String:error];
                NSLog(@"Error: %@", errMsg);
            }
            @throw [NSException exceptionWithName:@"Fail to begin transaction."
                                           reason:[NSString stringWithFormat:@"Result: %ld, error: %@", result, errMsg]
                                         userInfo:nil];
        }
        
        // @"ALTER TABLE User ADD COLUMN testColumn TEXT";
        sql = @"ALTER TABLE entity ADD COLUMN counterparty_id INTEGER";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSString *errMsg = nil;
            if(error){
                errMsg = [NSString stringWithUTF8String:error];
                NSLog(@"Error: %@", errMsg);
            }
            @throw [NSException exceptionWithName:@"Fail to add column counterparty_id entity."
                                           reason:[NSString stringWithFormat:@"Result: %ld, error: %@", result, errMsg]
                                         userInfo:nil];
        }
        
        // @"ALTER TABLE User ADD COLUMN testColumn TEXT";
        sql = @"ALTER TABLE entity ADD COLUMN counterparty_type_id INTEGER";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSString *errMsg = nil;
            if(error){
                errMsg = [NSString stringWithUTF8String:error];
                NSLog(@"Error: %@", errMsg);
            }
            @throw [NSException exceptionWithName:@"Fail to add column counterparty_type_id entity."
                                           reason:[NSString stringWithFormat:@"Result: %ld, error: %@", result, errMsg]
                                         userInfo:nil];
        }
        
        // Delete version records
        sql = @"DELETE FROM config WHERE key IN ('DatabaseSchemeVersion', 'DatabaseMajorVersion', 'DatabaseMinorVersion')";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSString *errMsg = nil;
            if(error){
                errMsg = [NSString stringWithUTF8String:error];
                NSLog(@"Error: %@", errMsg);
            }
            @throw [NSException exceptionWithName:@"Fail to delete databaseSchemeVersion record."
                                           reason:[NSString stringWithFormat:@"Result: %ld, error: %@", result, errMsg]
                                         userInfo:nil];
        }
        
        // Insert version record
        sql = @"INSERT INTO config (key, type, value) VAlUES ('DatabaseSchemeVersion', 'i', 2)";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSString *errMsg = nil;
            if(error){
                errMsg = [NSString stringWithUTF8String:error];
                NSLog(@"Error: %@", errMsg);
            }
            @throw [NSException exceptionWithName:@"Fail to insert databaseSchemeVersion record."
                                           reason:[NSString stringWithFormat:@"Result: %ld, error: %@", result, errMsg]
                                         userInfo:nil];
        }
        
        // COMMIT
        sql = @"COMMIT";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSString *errMsg = nil;
            if(error){
                errMsg = [NSString stringWithUTF8String:error];
                NSLog(@"Error: %@", errMsg);
            }
            @throw [NSException exceptionWithName:@"Fail to commit transaction."
                                           reason:[NSString stringWithFormat:@"Result: %ld, error: %@", result, errMsg]
                                         userInfo:nil];
        }
        
        updateResult = YES;
    }
    @catch(NSException *ex) {
        NSLog(@"YYGUpdater exception handled. Message: %@", [ex description]);
        
        // ROLLBACK?
        sql = @"ROLLBACK";
        result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error);
        if(result != SQLITE_OK) {
            NSLog(@"Fail to rollback transaction.");
            if(error)
                NSLog(@"Error: %@", [NSString stringWithUTF8String:error]);
        }
        
        updateResult = NO;
    }
    @finally {
        sqlite3_close(db);
        return [NSNumber numberWithBool:updateResult];
    }
}

/**
 Update to verstion 1.1(13).
 [+] Make directory for local backup: .../Documents/Backup
 [+] All local backups must be move to .../Documents/Backup
 
 @return Is update success or not
 */
- (NSNumber *)updateToVersionMajor1Minor1Build13 {
#ifdef DEBUG
    NSLog(@"Update to version 1.1(13)...");
#endif
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *backupDirPath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], @"Backup"];
    BOOL isDirectory;
    
    if([fileManager fileExistsAtPath:backupDirPath isDirectory:&isDirectory]){
        return @YES;
    } else {
        if (![fileManager createDirectoryAtPath:backupDirPath withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Can not create local backup directory");
            return @NO;
        }
        
        NSArray *fileNames = [YGTools namesAtPath:[YGTools documentsDirectoryPath]];
        NSMutableArray *backupFileNames = [NSMutableArray array];
        
        for (NSString *name in fileNames){
            if ([self isBackupName:name]){
                [backupFileNames addObject:name];
            }
        }
        
        if ([backupFileNames count] > 0){
            for (NSString *name in backupFileNames){
                
                NSString *oldName = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], name];
                NSString *newName = [NSString stringWithFormat:@"%@/%@/%@", [YGTools documentsDirectoryPath], @"Backup", [name lastPathComponent]];
                
                if(![fileManager moveItemAtPath:oldName toPath:newName error:&error]){
                    NSLog(@"Fail to move backup file to new path. Error: %@", [error description]);
                    return @NO;
                }
            }
        }
        return @YES;
    }
}

@end

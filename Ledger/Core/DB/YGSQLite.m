//
//  YGSQLite.m
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

/*
 Naming 
 1. Primary key of table must contains table name and _id, ex: counterparty_id
 */

#import <sqlite3.h>
#import "YGSQLite.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"
#import "YYGDBLog.h"

// fill database with common and test or release data
#import "YYGDataCommon.h"

#import "YYGDataRelease.h"
/*
#ifdef DEBUG
    #import "YYGDataTest.h"
#else
    #import "YYGDataRelease.h"
#endif
*/
@interface YGSQLite()

- (void)checkDatabase;

@end

@implementation YGSQLite

- (instancetype) init{
    self = [super init];
    if(self){
        [self checkDatabase];
    }
    return self;
}


+ (YGSQLite *)sharedInstance{
    static YGSQLite *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YGSQLite alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Create tables

- (void)createTables {
    
#ifdef DEBUG_REBUILD_BASE
    if([self isTableExist:@"log"])
        [self dropTable:@"log"];
#endif
    
    // create log
    NSString *createSql = @"CREATE TABLE IF NOT EXISTS log "
    "(log_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "created TEXT NOT NULL, "
    "created_unix REAL NOT NULL, "
    "message TEXT NOT NULL"
    ");";
    
    [self createTable:@"log" createSQL:createSql];
    
    [YYGDBLog logEvent:@"Table log created"];
    
#ifdef DEBUG_REBUILD_BASE
    if([self isTableExist:@"config"])
        [self dropTable:@"config"];
#endif

    createSql = @"CREATE TABLE IF NOT EXISTS config "
    "(config_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "key TEXT NOT NULL, "
    "type TEXT NOT NULL, "
    "value TEXT NOT NULL"
    ");";
    
    [self createTable:@"config" createSQL:createSql];
    
    [YYGDBLog logEvent:@"Table config created"];
    
#ifdef DEBUG_REBUILD_BASE
    if([self isTableExist:@"category"])
        [self dropTable:@"category"];
#endif
    
    createSql = @"CREATE TABLE IF NOT EXISTS category "
    "(category_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "category_type_id INTEGER NOT NULL, "
    "name TEXT NOT NULL, "
    "active INTEGER NOT NULL, "
    "created TEXT NOT NULL, "
    "modified TEXT, "
    "sort INTEGER NOT NULL, "
    "symbol TEXT, "
    "attach INTEGER NOT NULL, "
    "parent_id INTEGER, "
    "comment TEXT ,"
    "uuid TEXT NOT NULL"
    ");";
    
    [self createTable:@"category" createSQL:createSql];
    
    [YYGDBLog logEvent:@"Table category created"];
    
#ifdef DEBUG_REBUILD_BASE
    if([self isTableExist:@"entity"])
        [self dropTable:@"entity"];
#endif
    
    createSql = @"CREATE TABLE IF NOT EXISTS entity "
    "(entity_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "entity_type_id INTEGER NOT NULL, "
    "name TEXT NOT NULL, "
    "sum REAL, "
    "currency_id INTEGER NOT NULL, "
    "active INTEGER NOT NULL, "
    "created TEXT NOT NULL, "
    "modified TEXT, "
    "attach INTEGER NOT NULL, "
    "sort INTEGER NOT NULL, "
    "comment TEXT, "
    "uuid TEXT NOT NULL, "
    "counterparty_id INTEGER, "
    "counterparty_type_id INTEGER"
    ");";
    
    [self createTable:@"entity" createSQL:createSql];
    
    [YYGDBLog logEvent:@"Table entity created"];
    
#ifdef DEBUG_REBUILD_BASE
    if([self isTableExist:@"operation"])
        [self dropTable:@"operation"];
#endif
    
    createSql = @"CREATE TABLE IF NOT EXISTS operation "
    "(operation_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "operation_type_id INTEGER NOT NULL, "
    "source_id INTEGER NOT NULL, "
    "target_id INTEGER NOT NULL, "
    "source_sum REAL NOT NULL, "
    "source_currency_id INTEGER NOT NULL, "
    "target_sum REAL NOT NULL, "
    "target_currency_id INTEGER NOT NULL, "
    "day TEXT NOT NULL, "
    "day_unix REAL NOT NULL, "
    "created TEXT NOT NULL, "
    "created_unix REAL NOT NULL, "
    "modified TEXT NOT NULL, "
    "modified_unix REAL NOT NULL, "
    "comment TEXT ,"
    "uuid TEXT NOT NULL"
    ");";
    
    [self createTable:@"operation" createSQL:createSql];
    
    [YYGDBLog logEvent:@"Table operation created"];
    
#ifdef DEBUG
#if (TARGET_OS_SIMULATOR)
    [self debugCopyLinkToDatabaseOnDesktop];
#endif
#endif
}


#pragma mark - Fill category and entity

- (void)fillTables {
    
    addCommonCurrencies();
    
    addReleaseAccounts();
    
    addReleaseExpenseCategories();
    
    addReleaseIncomeSources();
    
    /*
    
#ifdef DEBUG
    
    addTestAccounts();
    
    addTestExpenseCategories();
    
    addTestIncomeSources();
    
#else
    
    addReleaseAccounts();
    
    addReleaseExpenseCategories();
    
    addReleaseIncomeSources();
    
#endif
    
#ifdef FILL_TEST_DATA
    addTestOperations();
#endif
     */
    
    [YYGDBLog logEvent:@"Database filled by data"];
}


#pragma mark - Check actions

- (void)checkDatabase{
    
    sqlite3 *db = [self database];
    
#ifdef DEBUG
    NSLog(@"Path to db: %@", [YGSQLite databaseFullName]);
#endif

    sqlite3_close(db);
    
#ifdef DEBUG
    #if (TARGET_OS_SIMULATOR)
    [self debugCopyLinkToDatabaseOnDesktop];
    #endif
#endif
}


- (NSInteger)addRecord:(NSArray *)fieldsOfItem insertSQL:(NSString *)insertSQL{
    
    sqlite3 *db = [self database];

    sqlite3_stmt *stmt;
    
    NSInteger resultId = -1;
    
    @try {
        
        NSInteger resultSqlitePrepare = sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &stmt, nil);
        
        if(resultSqlitePrepare == SQLITE_OK){
            
            for(int i = 0; i < [fieldsOfItem count]; i++){
                
                id field = fieldsOfItem[i];
                
                if([field isKindOfClass:[NSNumber class]]){
                    
                    if(strcmp([field objCType], @encode(double)) == 0){
                        if(sqlite3_bind_double(stmt, i+1, [field doubleValue]) != SQLITE_OK){
                            NSLog(@"Can not bind double");
                        }
                    }
                    else if((strcmp([field objCType], @encode(long)) == 0)
                            || (strcmp([field objCType], @encode(int)) == 0)){
                        if(sqlite3_bind_int(stmt, i+1, [field intValue]) != SQLITE_OK){
                            NSLog(@"Can not bind int");
                        }
                    }
                    else if(strcmp([field objCType], @encode(BOOL)) == 0){ // BOOL as int, Do not work, see below
                        if(sqlite3_bind_int(stmt, i+1, [field boolValue]) != SQLITE_OK){
                            NSLog(@"Can not bind bool");
                        }
                    }
                    else if(strcmp([field objCType], "c") == 0){ // BOOL as char, crutch!
                        int intBool = (int)[field boolValue];
                        if(sqlite3_bind_int(stmt, i+1, intBool) != SQLITE_OK){
                            NSLog(@"Can not bind bool");
                        }
                    }
                    else{
                        @throw [NSException exceptionWithName:@"-[YGSQLite fillTable:items:updateSQL]" reason:[NSString stringWithFormat:@"Can not bind NSNumber object. field type: %s, column: %d, class: %@", [field objCType], i+1, NSStringFromClass([field class])] userInfo:nil];
                    }
                }
                else if([field isKindOfClass:[NSString class]]){
                    if(sqlite3_bind_text(stmt, i+1, [field UTF8String], -1, NULL) != SQLITE_OK){
                        NSLog(@"Can not bind text");
                    }
                }
                else if([field isKindOfClass:[NSNull class]]){
                    if(sqlite3_bind_null(stmt, i+1) != SQLITE_OK){
                        NSLog(@"Can not bind null");
                    }
                }
                else{
                    NSLog(@"undefined item class: %@, description: %@", [field class], [field description]);
                    @throw [NSException exceptionWithName:@"-[YGSQLite addRecord:insertSQL" reason:@"Can not choose bind functions to undefined item" userInfo:nil];
                }
                
            }
            
            NSInteger resultSqliteStep = sqlite3_step(stmt);
            if(resultSqliteStep != SQLITE_DONE)
                NSLog(@"sqlite_step() fail: Returned code: %@", [NSString stringWithUTF8String:sqlite3_errmsg(db)]);
            
            // 9223372036854775807 not enough?
            resultId = (NSInteger)sqlite3_last_insert_rowid(db);
        }
        else{
            
            NSLog(@"-[YGSQLite addRecord:insertSQL:] .. sqlite_prepare_v2() fail. Returned code: %ld", (long)resultSqlitePrepare);
        }
        
        sqlite3_finalize(stmt);
    }
    @catch(NSException *ex){
        
        NSLog(@"Fail in -[YGSQLite addRecord:insertSQL:]. Exception: %@", [ex description]);
    }
    @finally {
        
        sqlite3_close(db);
        
        return resultId;
    }
}

/*
 SQL query without return. Suits for delete, update.
 */
- (void)execSQL:(NSString *)sqlQuery {
    
    sqlite3 *db = [self database];
    
    char* error;
    
    int result = sqlite3_exec(db, [sqlQuery UTF8String], nil, nil, &error);
    
    if (result != SQLITE_OK) {
        NSLog(@"YGSQLite execSQL: fails. \nSQL: %@\nerror: %@", sqlQuery, [NSString stringWithUTF8String:error]);
    }
}


- (void)removeRecordWithSQL:(NSString *)deleteSQL{
    
    sqlite3 *db = [self database];
    
    char* error;
    
    int result = sqlite3_exec(db, [deleteSQL UTF8String], nil, nil, &error);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error in deleting");
    }
}

- (void)fillTable:(NSString *)tableName items:(NSArray *)items updateSQL:(NSString *)updateSQL{
    
    sqlite3 *db = [self database];
    
    NSInteger rowCount = 0;
    
    for(int i = 0; i < [items count]; i++){
        
        char *errorMsg = NULL;
        sqlite3_stmt *stmt;
        
        if(sqlite3_prepare_v2(db, [updateSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
            
            NSArray *item = items[i];
            
            for(int j = 0; j < [item count]; j++){
                
                if([item[j] isKindOfClass:[NSNumber class]]){
                    
                    if(strcmp([item[j] objCType], @encode(double)) == 0){
                        if(sqlite3_bind_double(stmt, j+1, [item[j] doubleValue]) != SQLITE_OK){
                            NSLog(@"Can not bind double");
                        }
                    }
                    else if(strcmp([item[j] objCType], @encode(int)) == 0){
                        if(sqlite3_bind_int(stmt, j+1, [item[j] intValue]) != SQLITE_OK){
                            NSLog(@"Can not bind int");
                        }
                    }
                    else if(strcmp([item[j] objCType], @encode(BOOL)) == 0){ // BOOL as int
                        if(sqlite3_bind_int(stmt, j+1, [item[j] intValue]) != SQLITE_OK){
                            NSLog(@"Can not bind bool");
                        }
                    }
                    else{
                        @throw [NSException exceptionWithName:@"-[YGSQLite fillTable:items:updateSQL]" reason:@"Can not bind NSNumber object" userInfo:nil];
                    }
                }
                else if([item[j] isKindOfClass:[NSString class]]){
                    if(sqlite3_bind_text(stmt, j+1, [item[j] UTF8String], -1, NULL) != SQLITE_OK){
                        NSLog(@"Can not bind text");
                    }
                }
                else if([item[j] isKindOfClass:[NSNull class]]){
                    if(sqlite3_bind_null(stmt, j+1) != SQLITE_OK){
                        NSLog(@"Can not bind null");
                    }
                }
                else{
                    NSLog(@"undefined item class: %@, description: %@", [item[j] class], [item[j] description]);
                    @throw [NSException exceptionWithName:@"-[YGSQLite fillTable:items:updateSQL" reason:@"Can not choose bind functions to undefined item" userInfo:nil];
                }
            } //for(int j = 0; j < [item count]; j++){
            
            rowCount += 1;
            
        } //if(sqlite3_prepare_v2(db, [updateSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
        
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"Error in update table '%@', message: '%@'.", tableName, [NSString stringWithUTF8String:errorMsg]);
            NSAssert(0, @"Error in update table: '%@', message: %s.", tableName, errorMsg);
        }
        
        sqlite3_finalize(stmt);
        
    } //for(int i = 0; i < [items count]; i++){
    
    sqlite3_close(db);
}


- (NSArray *)selectWithSqlQuery:(NSString *)sqlQuery {
#ifdef PERFORMANCE
    NSLog(@"YGSQLite.selectWithSqlQuery:");
#endif
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    sqlite3 *db = [self database];
    
    sqlite3_stmt *statement;
    
    int resultSqlitePrepare = sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil);
    
    if (resultSqlitePrepare == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableArray *row = [[NSMutableArray alloc] init];
            
            for(int i = 0; i < sqlite3_column_count(statement); i++){
                
                int columnType = sqlite3_column_type(statement, i);
                
                if(columnType == 1){ //int
                    
                    int intVal = sqlite3_column_int(statement, i);
                    [row addObject:[NSNumber numberWithInt:intVal]];
                }
                else if(columnType == 2){ // double
                    
                    double doubleVal = sqlite3_column_double(statement, i);
                    [row addObject:[NSNumber numberWithDouble:doubleVal]];
                }
                else if(columnType == 3){ //text
                    
                    const char *charValue = (char *)sqlite3_column_text(statement, i);
                    if(charValue != NULL)
                        [row addObject:[[NSString alloc] initWithUTF8String:charValue]];
                    else
                        [row addObject:[NSNull null]];
                }
                else if(columnType == 5){
                    [row addObject:[NSNull null]];
                }
                else {
                    @throw [NSException exceptionWithName:@"-[YGSQLite selectWithSqlQuery]" reason:@"Can not get value of selected type" userInfo:nil];
                }
            }
            
            [result addObject:row];
        }
        sqlite3_finalize(statement);
    }
    else{
        NSLog(@"-[YGSQLite selectWithSqlQuery] .. sqlite3_prepare_v2() != SQLITE_OK. Result: %d", resultSqlitePrepare);
    }
    
    sqlite3_close(db);
    
#ifdef PERFORMANCE
    NSLog(@"<< selectWithSqlQuery finished");
#endif

    if([result count] > 0)
        return [result copy];
    else
        return nil;
}

- (BOOL)isTableExist:(NSString *)tableName{
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';", tableName];
    
    sqlite3 *db = [self database];

    sqlite3_stmt *statement;
    int rowCount = 0;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String],
                           -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
                        
            rowCount += 1;
            
        }
        sqlite3_finalize(statement);
    }

    
    sqlite3_close(db);
    
    if(rowCount == 0)
        return NO;
    else
        return YES;
}

- (BOOL)isTableEmpty:(NSString *)tableName{
    
    sqlite3 *db = [self database];
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT %@_id FROM %@ LIMIT 1;", tableName, tableName];
    sqlite3_stmt *statement;
    int rowCount = 0;
    
    if (sqlite3_prepare_v2(db, [querySQL UTF8String],
                           -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int table_id = sqlite3_column_int(statement, 0);
            
            table_id = 0; // shit! only to remove warning
            
            //NSLog(@"id: %ld", (long)table_id);
            
            rowCount += 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(db);
    
    if(rowCount <= 0)
        return YES;
    else
        return NO;
}

- (void)createTable:(NSString *)tableName createSQL:(NSString *)createSQL{
    
    sqlite3 *db = [self database];
    char *errorMsg;
    
    // drop category
    if([self isTableExist:tableName])
        [self dropTable:tableName];

    if (sqlite3_exec (db, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(db);
        
        //NSAssert(0, @"Error creating table: %s", errorMsg);
        @throw [NSException exceptionWithName:@"-[YGSQLite createTable:tableName createSQL:]" reason:[NSString stringWithFormat:@"Can not create table %@. Error: %@", tableName, [NSString stringWithUTF8String:errorMsg]] userInfo:nil];
    }
    
    sqlite3_close(db);
}

- (void)dropTable:(NSString *)tableName{
    
    sqlite3 *db = [self database];
    char *errorMsg;
    NSString *dropSQL = [NSString stringWithFormat:@"DROP TABLE %@;", tableName];
    
    if (sqlite3_exec (db, [dropSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        
        // close db
        sqlite3_close(db);
        
        // NSAssert(0, @"Error droping table: %s", errorMsg);
        @throw [NSException exceptionWithName:@"-[YGSQLite dropTable]" reason:[NSString stringWithFormat:@"Can not drop table %@. Error: %@", tableName, [NSString stringWithUTF8String:errorMsg]] userInfo:nil];
    }
    else{
#ifdef DEBUG
        NSLog(@"Table %@ dropped", tableName);
#endif
    }
    
    sqlite3_close(db);
}

- (sqlite3 *)database{
    
    sqlite3 *db;
    
    NSString *path = [YGSQLite databaseFullName];
    
    int result = sqlite3_open([path UTF8String], &db);
    
    if(result != SQLITE_OK){
        NSLog(@"Can not open/create sqlite db.");
        @throw [NSException exceptionWithName:@"-[YGSQLite database]" reason:[NSString stringWithFormat:@"Can not open/create sql database. Path: %@", path] userInfo:nil];
    }
    
    return db;
}


/**
 Return work database full name.
 
 @return Full name of work database.
 */
+ (NSString *)databaseFullName {
    
    static NSString *databaseFullName = nil;
    
    if(databaseFullName)
        return [databaseFullName copy];
    else{
        NSString *documentsDirectory = [YGTools documentsDirectoryPath];
        
        databaseFullName = [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
        
        return [databaseFullName copy];
    }
}

/**
 
 */
+ (NSString *)databaseName {
    return kDatabaseName;
}

- (NSInteger)executeSql:(NSString *)sqlQuery {
    
    NSInteger result = NSNotFound;
    sqlite3 *db = [self database];
    const char *sql = [sqlQuery UTF8String];
    char *errorMessage = 0;
    
    result = sqlite3_exec(db, sql, NULL, NULL, &errorMessage);
    
    if(result != SQLITE_OK) {
        NSLog(@"YGSQLite.executeSql fails. Return: %ld, error message: %@", result, [NSString stringWithUTF8String:errorMessage]);
        sqlite3_free(errorMessage);
    }
    
    sqlite3_close(db);
    return result;
}

- (BOOL)hasColumn:(NSString *)column inTable:(NSString *)table {
    
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@", column, table];
    
    if([self executeSql:sql] != SQLITE_OK)
        return NO;
    else
        return YES;
}

- (void)debugCopyLinkToDatabaseOnDesktop {
    
#ifdef DEBUG
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtPath:@"/Users/yanikng/Desktop/ledger.db.sqlite" error:&error];
    if(error){
        NSLog(@"Error in remove old symbolic link. Error: %@", [error description]);
    }
    [fm createSymbolicLinkAtPath:@"/Users/yanikng/Desktop/ledger.db.sqlite" withDestinationPath:[YGSQLite databaseFullName] error:&error];
    if(error){
        NSLog(@"Error in create symbolic link. Error: %@", [error description]);
    }
#endif
}

@end

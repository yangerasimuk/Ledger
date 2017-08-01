//
//  YGSQLite.m
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

/*
 Naming 
 1. Primary key of table must contains table name and _id, ex: person_id
 */

#import <sqlite3.h>
#import "YGSQLite.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

// fill database with common and test or release data
#import "YYGDataCommon.h"

#ifdef DEBUG
    #import "YYGDataTest.h"
#else
    #import "YYGDataRelease.h"
#endif

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
    
    // drop category
    if([self isTableExist:@"category"])
        [self dropTable:@"category"];
    
    // create category
    NSString *createSql = @"CREATE TABLE IF NOT EXISTS category "
    "(category_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "category_type_id INTEGER NOT NULL, "
    "name TEXT NOT NULL, "
    "active INTEGER NOT NULL, "
    "active_from TEXT NOT NULL, "
    "active_to TEXT, "
    "sort INTEGER NOT NULL, "
    "symbol TEXT, "
    "attach INTEGER NOT NULL, "
    "parent_id INTEGER, "
    "comment TEXT"
    ");";
    
    [self createTable:@"category" createSQL:createSql];
    
    // drop entity
    if([self isTableExist:@"entity"])
        [self dropTable:@"entity"];
    
    // create entity
    createSql = @"CREATE TABLE IF NOT EXISTS entity "
    "(entity_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "entity_type_id INTEGER NOT NULL, "
    "name TEXT NOT NULL, "
    "sum REAL, "
    "currency_id INTEGER NOT NULL, "
    "active INTEGER NOT NULL, "
    "active_from TEXT NOT NULL, "
    "active_to TEXT, "
    "attach INTEGER NOT NULL, "
    "sort INTEGER NOT NULL, "
    "comment TEXT"
    ");";
    
    [self createTable:@"entity" createSQL:createSql];
    
    // drop operation
    if([self isTableExist:@"operation"])
        [self dropTable:@"operation"];
    
    // create operation
    createSql = @"CREATE TABLE IF NOT EXISTS operation "
    "(operation_id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "operation_type_id INTEGER NOT NULL, "
    "source_id INTEGER NOT NULL, "
    "target_id INTEGER NOT NULL, "
    "source_sum REAL NOT NULL, "
    "source_currency_id INTEGER NOT NULL, "
    "target_sum REAL NOT NULL, "
    "target_currency_id INTEGER NOT NULL, "
    "created TEXT NOT NULL, "
    "created_unix REAL NOT NULL ,"
    "modified TEXT NOT NULL, "
    "modified_unix REAL NOT NULL ,"
    "comment TEXT"
    ");";
    
    [self createTable:@"operation" createSQL:createSql];
}


#pragma mark - Fill category and entity

- (void)fillDatabase {
    
    addCommonCurrencies();
    
#ifdef DEBUG
    
    addTestAccounts();
    
    addTestExpenseCategories();
    
    addTestIncomeSources();
    
#ifdef FILL_TEST_DATA
    addTestOperations();
#endif
    
    
#else
    
    addReleaseAccounts();
    
    addReleaseExpenseCategories();
    
    addReleaseIncomeSources();
    
#endif
    
    
}


#pragma mark - Check actions

- (void)checkDatabase{
    
    sqlite3 *db = [self database];
    
    NSLog(@"Path to db: %@", [YGSQLite databaseFullName]);

    sqlite3_close(db);
    
#ifndef APP_STORE
    
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


- (NSInteger)addRecord:(NSArray *)fieldsOfItem insertSQL:(NSString *)insertSQL{
    
    NSInteger resultId = -1;
    sqlite3 *db = [self database];

    //char *errorMsg = NULL;
    sqlite3_stmt *stmt;

    if(sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
        
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
                else if(strcmp([field objCType], @encode(BOOL)) == 0){ // BOOL as int
                    if(sqlite3_bind_int(stmt, i+1, [field intValue]) != SQLITE_OK){
                        NSLog(@"Can not bind bool");
                    }
                }
                else{
                    @throw [NSException exceptionWithName:@"-[YGSQLite fillTable:items:updateSQL]" reason:@"Can not bind NSNumber object" userInfo:nil];
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
            
        } //for(int j = 0; j < [item count]; j++){
        
        if((long)sqlite3_step(stmt) != SQLITE_DONE){
            NSString *errorMsg = [NSString stringWithUTF8String:sqlite3_errmsg(db)];
            NSLog(@"Error message: %@", errorMsg);
        }
        
        NSInteger result = (long)sqlite3_step(stmt);
        //printf("\nresult of sqlite3_step: %ld", result);
        
        resultId = sqlite3_last_insert_rowid(db);
        
    } //if(sqlite3_prepare_v2(db, [updateSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
    
    /*
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        
        printf("\n%s", errorMsg);
        NSAssert(0, @"Error updating table: %s", errorMsg);
        
    }
     */
    
    sqlite3_finalize(stmt);

    sqlite3_close(db);
    
    return resultId;
}

/*
 SQL query without return. Suits for delete, update.
 */
- (void)execSQL:(NSString *)sqlQuery{

    sqlite3 *db = [self database];
    
    char* error;
    
    int result = sqlite3_exec(db, [sqlQuery UTF8String], nil, nil, &error);
    
    if (result != SQLITE_OK) {
        NSLog(@"Error in sql query");
        if(strlen(error) > 0){
            NSLog(@"Error message: %@", [NSString stringWithUTF8String:error]);
        }
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
    
    NSLog(@"sqlQuery: %@", sqlQuery);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    sqlite3 *db = [self database];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
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
    
    sqlite3_close(db);

    return [result copy];
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

@end

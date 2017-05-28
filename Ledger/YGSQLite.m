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

#import "YGSQLite.h"
#import <sqlite3.h>

static NSString *kDateTimeFormat = @"yyyy-MM-dd HH:mm:ss Z";


typedef void(^OpenSQLiteDB)(void);

@interface YGSQLite(){
    
    
}

- (NSString *)pathToDB;

- (void)checkDB;
- (void)checkDictionary;

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)string;


@end

@implementation YGSQLite

- (instancetype) init{
    self = [super init];
    if(self){
        
        [self checkDB];
        [self checkDictionary];
        
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

/* 
 */
- (void)checkDB{
    
    sqlite3 *db = [self dataBase];

    sqlite3_close(db);
}

- (void)checkDictionary{
    
    if([self isTableEmpty:@"dictionary"] == YES){
    
        // drop dictionary
        [self dropTable:@"dictionary"];
        
        // create dictionary
        NSString *createSQL = @"CREATE TABLE IF NOT EXISTS dictionary "
        "(dictionary_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, sort INTEGER);";
        [self createTable:@"dictionary" createSQL:createSQL];
        
        NSArray *dictionaryItems = @[
  @[@"Currency", @100],
  @[@"Expense category", @101],
  @[@"Income source", @102],
  @[@"Creditor", @103],
  @[@"Debtor", @104],
  @[@"Tag", @105]
  ];
        NSString *updateSQL = @"INSERT OR REPLACE INTO dictionary (name, sort) "
        "VALUES (?, ?);";
        
        // fill dictionary
        [self fillTable:@"dictionary" items:dictionaryItems updateSQL:updateSQL];
        
        // drop dictionary_item
        [self dropTable:@"dictionary_item"];
        
        // create dictionary_item
        NSString *createSQL2 = @"CREATE TABLE IF NOT EXISTS dictionary_item "
        "(dictionary_item_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "active INTEGER, active_from TEXT, active_to TEXT, name TEXT, sort INTEGER, symbol TEXT, "
        "comment TEXT, parent_id, "
        "dictionary_id INTEGER NOT NULL, FOREIGN KEY (dictionary_id) REFERENCES dictionary(dictionary_id) "
        ");";
        
        [self createTable:@"dictionary_item" createSQL:createSQL2];
        
        // fill dictionary_item
        NSArray *dictionaryItems2 = @[
                                      @[@1,
                                        [YGSQLite stringFromDate:[NSDate date]],
                                        [NSNull null],
                                        @"Российский рубль",
                                        @"100",
                                        @"₽",
                                        @"Валюта Российской Федерации",
                                        [NSNull null],
                                        @1],
                                      @[@1,
                                        [YGSQLite stringFromDate:[NSDate date]],
                                        [NSNull null],
                                        @"Доллар США",
                                        @"101",
                                        @"$",
                                        @"Валюта США",
                                        [NSNull null],
                                        @1],
                                      ];
        
        NSString *updateSQL2 = @"INSERT OR REPLACE INTO dictionary_item (active, active_from, active_to, name, sort, symbol, comment, parent_id, dictionary_id) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
        [self fillTable:@"dictionary_item" items:dictionaryItems2 updateSQL:updateSQL2];
    }
    
}

- (void)fillTable:(NSString *)tableName items:(NSArray *)items updateSQL:(NSString *)updateSQL{
    sqlite3 *db = [self dataBase];
    
    for(int i = 0; i < [items count]; i++){
        
        char *errorMsg = NULL;
        sqlite3_stmt *stmt;
        
        if(sqlite3_prepare_v2(db, [updateSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
            
            NSArray *item = items[i];
            
            for(int j = 0; j < [item count]; j++){
                
                if([item[j] isKindOfClass:[NSNumber class]]){
                    if(sqlite3_bind_int(stmt, j+1, [item[j] intValue]) != SQLITE_OK){
                        NSLog(@"Can not bind int");
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
                }
                
            } //for(int j = 0; j < [item count]; j++){
            
        } //if(sqlite3_prepare_v2(db, [updateSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSAssert(0, @"Error updating table: %s", errorMsg);
        }
        sqlite3_finalize(stmt);
        
    } //for(int i = 0; i < [items count]; i++){
    
    sqlite3_close(db);
}


- (BOOL)isTableEmpty:(NSString *)tableName{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    sqlite3 *db = [self dataBase];
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT %@_id FROM %@ LIMIT 1;", tableName, tableName];
    sqlite3_stmt *statement;
    int rowCount = 0;
    
    if (sqlite3_prepare_v2(db, [querySQL UTF8String],
                           -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int table_id = sqlite3_column_int(statement, 0);
            
            NSLog(@"id: %ld", (long)table_id);
            
            rowCount += 1;
            
        }
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(db);
    
    if(rowCount <= 0){
#ifdef FUNC_DEBUG
        NSLog(@"В таблице %@ записей нет!", tableName);
#endif
        return YES;
    }
    else{
#ifdef FUNC_DEBUG
        NSLog(@"В таблице %@ записи есть.", tableName);
#endif
        return NO;
    }
}

- (void)createTable:(NSString *)tableName createSQL:(NSString *)createSQL{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    sqlite3 *db = [self dataBase];
    char *errorMsg;

    if (sqlite3_exec (db, [createSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(db);
        
        //NSAssert(0, @"Error creating table: %s", errorMsg);
        @throw [NSException exceptionWithName:@"-[YGSQLite createTable:tableName createSQL:]" reason:[NSString stringWithFormat:@"Can not create table %@. Error: %@", tableName, [NSString stringWithUTF8String:errorMsg]] userInfo:nil];
    }
    else{
#ifdef FUNC_DEBUG
        NSLog(@"Table %@ successfully created", tableName);
#endif
    }
    

    sqlite3_close(db);
}

- (void)dropTable:(NSString *)tableName{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    sqlite3 *db = [self dataBase];
    char *errorMsg;
    NSString *dropSQL = [NSString stringWithFormat:@"DROP TABLE %@;", tableName];
    
    if (sqlite3_exec (db, [dropSQL UTF8String],
                      NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(db);
        
        //NSAssert(0, @"Error droping table: %s", errorMsg);
        @throw [NSException exceptionWithName:@"-[YGSQLite dropTable]" reason:[NSString stringWithFormat:@"Can not drop table %@. Error: %@", tableName, [NSString stringWithUTF8String:errorMsg]] userInfo:nil];
        
    }
    else{
#ifdef FUNC_DEBUG
        NSLog(@"Table %@ successfully droped", tableName);
#endif
    }
    
    
    sqlite3_close(db);
}

- (sqlite3 *)dataBase{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    sqlite3 *db;
    
    NSString *path = [self pathToDB];
    
    int result = sqlite3_open([path UTF8String], &db);
    
    if(result == SQLITE_OK){
#ifdef FUNC_DEBUG
        NSLog(@"DB successfully open.");
#endif
    }
    else{
        NSLog(@"Can not open/create sqlite db.");
        @throw [NSException exceptionWithName:@"-[YGSQLite dataBase]" reason:[NSString stringWithFormat:@"Can not open/create sql database. Path: %@", path] userInfo:nil];
    }
    
    return db;
}


/**
 Return full path to sql db on iOS device
 */
- (NSString *)pathToDB{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathToDB = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
    
#ifdef FUNC_DEBUG
    NSLog(@"Path to db: %@", pathToDB);
#endif

    return pathToDB;
}

#pragma mark - Other tools
+ (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter dateFromString:string];
}


@end

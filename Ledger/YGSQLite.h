//
//  YGSQLite.h
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGSQLite : NSObject

+ (NSString *)databaseName;
+ (NSString *)databaseFullName;

- (instancetype) init;
+ (YGSQLite *)sharedInstance;

- (void)createTables;

- (void)fillDatabase;
- (void)fillTable:(NSString *)tableName items:(NSArray *)items updateSQL:(NSString *)updateSQL;

- (NSInteger)addRecord:(NSArray *)fieldsOfItem insertSQL:(NSString *)insertSQL;
- (NSArray *)selectWithSqlQuery:(NSString *)sqlQuery;
- (void)removeRecordWithSQL:(NSString *)deleteSQL;
- (void)execSQL:(NSString *)sqlQuery;



@end

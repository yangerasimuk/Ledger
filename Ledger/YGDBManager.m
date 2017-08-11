//
//  YGDBManager.m
//  Ledger
//
//  Created by Ян on 06/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGDBManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import <YGConfig.h>
#import "YYGLedgerDefine.h"
#import "YYGDBLog.h"
#import "YYGDBConfig.h"

@implementation YGDBManager

+ (YGDBManager *)sharedInstance{
    static YGDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGDBManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self){
        ;
    }
    return self;
}

/**
 Lazy load availible storages.
 */
- (NSMutableArray<id<YGStoraging>> *)storages {
    if(!_storages){
        
        // init storages array
        self.storages = [[NSMutableArray alloc] init];
        
        // get availible storages names
        YGConfig *config = [YGTools config];
        NSArray *storageNames = [config valueForKey:@"StoragesAvailible"];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for(NSString *name in storageNames){
            id<YGStoraging> storage = [YGStorage storageWithName:name];
            [result addObject:storage];
        }
        self.storages = result;
    }
    return _storages;
}

- (id<YGStoraging>)storageByType:(YGStorageType)type {
    
    for(id <YGStoraging> storage in self.storages){
        if([storage type] == YGStorageTypeLocal)
            return storage;
    }
    
    @throw [NSException exceptionWithName:@"-[YGDBManager storageByType]" reason:[NSString stringWithFormat:@"Fail to find storage with type: %ld", (long)type] userInfo:nil];
}

- (void)dealloc {
    NSLog(@"Object YGDBManager dealloc");
}


- (BOOL)databaseExists {
    
    NSString *pathDb = [YGSQLite databaseFullName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm fileExistsAtPath:pathDb])
        return YES;
    else
        return NO;
}


- (void)createDatabase {
    
    // Init of database
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    [sqlite createTables];
    
    [sqlite fillTables];
    
    // Set version of new database
    [YYGDBConfig setValue:@1 forKey:kDatabaseMajorVersionKey];
    [YYGDBConfig setValue:@0 forKey:kDatabaseMinorVersionKey];
    
    NSLog(@"Database version: %@.%@", [YYGDBConfig valueForKey:kDatabaseMajorVersionKey], [YYGDBConfig valueForKey:kDatabaseMinorVersionKey]);
}

- (NSString *)lastOperation {
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    NSString *sqlQuery = @"SELECT modified FROM operation ORDER BY modified_unix DESC LIMIT 1;";
        
    NSArray *rawList = [sqlite selectWithSqlQuery:sqlQuery];
    
    NSArray *operation = [rawList firstObject];
    
    NSString *date = [operation firstObject];
    
    return [date copy];

}

/**
 Return full name of current work database. Wraper on YGSQLite method.
 
 @return Current work database full name.
 */
- (NSString *)databaseFullName {
    return [YGSQLite databaseFullName];
}

@end

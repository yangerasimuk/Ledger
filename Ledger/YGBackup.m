//
//  YGBackup.m
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGBackup.h"
#import "YGTools.h"
#import "YGConfig.h"

@implementation YGBackup

- (instancetype)initWithName:(NSString *)name storage:(id<YGStoraging>)storage lastOperation:(NSString *)lastOperation backupDate:(NSString *)backupDate dbSize:(NSString *)dbSize {
    self = [super init];
    if(self){
        self.name = name;
        self.storage = storage;
        self.lastOperation = lastOperation;
        self.backupDate = backupDate;
        self.dbSize = dbSize;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name storage:(id<YGStoraging>)storage {
    
    YGConfig *config = [YGTools config];
    
    NSString *backupStorageKey = nil;
    if([storage type] == YGStorageTypeLocal)
        backupStorageKey = @"LocalBackup";
    else
        @throw [NSException exceptionWithName:@"-[YGDBInfo initWithName:type:storage:]" reason:[NSString stringWithFormat:@"Fail to get type of storage: %@", storage] userInfo:nil];
    
    NSArray *localBackups = [config valueForKey:backupStorageKey];
    
    NSDictionary *backup = [localBackups objectAtIndex:0];
    
    NSString *lastOperation = [backup objectForKey:@"LastOperation"];
    NSString *backupDate = [backup objectForKey:@"BackupDate"];
    NSString *dbSize = [backup objectForKey:@"BackupDBSize"];
    
    return [self initWithName:name storage:storage lastOperation:lastOperation backupDate:backupDate dbSize:dbSize];
}

@end

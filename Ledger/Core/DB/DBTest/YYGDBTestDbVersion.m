//
//  YYGDBTestDbVersion.m
//  Ledger
//
//  Created by Ян on 28.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDBTestDbVersion.h"
#import "YYGDBConfig.h"
#import "YYGLedgerDefine.h"

@implementation YYGDBTestDbVersion

- (instancetype)init {
    self = [super init];
    if (self){
        _rule = NSLocalizedString(@"DB_TEST_RULE_DB_VERSION_MUST_SUPPORTS_BY_APP", @"Database version must be support by the app.");
        _isContinue = NO;
    }
    return self;
}

- (BOOL)run {
    if([YYGDBConfig configDbMajorVersion] == kDatabaseMajorVersion
       && [YYGDBConfig configDbMinorVersion] == kDatabaseMinorVersion){
        _message = NSLocalizedString(@"DB_TEST_DB_VERSION_SUPPORTS_BY_APP", @"Database version supports by the app.");
        return YES;
    } else {
        _message = NSLocalizedString(@"DB_TEST_DB_VERSION_DOES_NOT_SUPPORT_BY_APP", @"Backup database of this version is not supported by the app.");
        return NO;
    }
}

@end

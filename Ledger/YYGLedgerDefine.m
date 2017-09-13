//
//  Define.m
//  Ledger
//
//  Created by Ян on 08/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGLedgerDefine.h"

// Application database name
NSString *const kDatabaseName = @"ledger.db.sqlite";

// Application xml config file name
NSString *const kAppConfigName = @"ledger.config.xml";

// Local time in human view format
NSString *const kDateTimeFormat = @"yyyy-MM-dd HH:mm:ss Z";

// Day of year format
NSString *const kDateTimeFormatOnlyDay = @"yyyy-MM-dd";

// Time format
NSString *const kDateTimeFormatOnlyTime = @"HH:mm";

// Timestamp for backup file name
NSString *const kDateTimeFormatForBackupName = @"yyyy-MM-dd-HH-mm-ssZ";

NSString *const kDateMinimum = @"2001-01-01 01:01:01 +0000";

NSString *const kDatabaseMajorVersionKey = @"DatabaseMajorVersion";
int kDatabaseMajorVersion = 1;

NSString *const kDatabaseMinorVersionKey = @"DatabaseMinorVersion";
int kDatabaseMinorVersion = 0;

int kKeyboardAppearanceDelay = 1;


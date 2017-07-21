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
    "short_name TEXT, "
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
    "owner_id INTEGER, "
    "sum NUMERIC, "
    "currency_id INTEGER, "
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
    "source_id INTEGER, "
    "target_id INTEGER, "
    "source_sum NUMERIC, "
    "source_currency_id INTEGER, "
    "target_sum NUMERIC, "
    "target_currency_id INTEGER, "
    "date TEXT ,"
    "date_unix NUMERIC ,"
    "comment TEXT"
    ");";
    
    [self createTable:@"operation" createSQL:createSql];
}

#pragma mark - Fill category and entity

- (void)fillTablesByCommonData {
    @throw [NSException exceptionWithName:@"-[YGSQLite fillTablesByCommonData]" reason:@"Method non implement" userInfo:nil];
}

- (void)fillTablesByTestData {
    
    [self addTestCurrencies];
    
    [self addTestAccounts];
    
    [self addTestExpenseCategories];
    
    [self addTestIncomeSources];
    
    [self addTestOperations];
    
}

- (void)addTestCurrencies {
    
    NSArray *categories = @[
                            @[
                                @1,
                                @"Российский рубль",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                @"RUB",
                                @"₽",
                                @1,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Белорусский рубль",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                @"BYN",
                                @"Br",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Гривна",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @102,
                                @"UAH",
                                @"₴",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Тенге",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @103,
                                @"KZT",
                                @"₸",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Доллар США",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @104,
                                @"USD",
                                @"$",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Евро",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @105,
                                @"EUR",
                                @"€",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Фунт",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @106,
                                @"GBP",
                                @"£",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Швейцарский франк",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @107,
                                @"CHF",
                                @"₣",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Юань",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @108,
                                @"CNY",
                                @"¥",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @1,
                                @"Иена",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @109,
                                @"JPY",
                                @"¥",
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            ];
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [self fillTable:@"category" items:categories updateSQL:insertSQL];

}

- (void)addTestAccounts {
    
    NSArray *entities = @[
                          @[
                              @1, // account
                              @"Кошелёк Ян",
                              [NSNull null],
                              @0,
                              @1, // rub
                              @1, // active
                              [YGTools stringFromDate:[NSDate date]],
                              [NSNull null],
                              @1, // attach
                              @100,
                              [NSNull null],
                              ],
                          @[
                              @1, // account
                              @"Кошелёк Маша",
                              [NSNull null],
                              @0,
                              @1, // rub
                              @1, // active
                              [YGTools stringFromDate:[NSDate date]],
                              [NSNull null],
                              @0, // attach
                              @101,
                              [NSNull null],
                              ],
                          @[
                              @1, // account
                              @"Карта Сбербанк Виза",
                              [NSNull null],
                              @0,
                              @1, // rub
                              @1, // active
                              [YGTools stringFromDate:[NSDate date]],
                              [NSNull null],
                              @0, // attach
                              @102,
                              [NSNull null],
                              ],
                          @[
                              @1, // account
                              @"Заначка в рублях",
                              [NSNull null],
                              @0,
                              @1, // rub
                              @1, // active
                              [YGTools stringFromDate:[NSDate date]],
                              [NSNull null],
                              @0, // attach
                              @103,
                              [NSNull null],
                              ],
                          
                          @[
                              @1, // account
                              @"Заначка в долларах",
                              [NSNull null],
                              @0,
                              @5, // usd
                              @1, // active
                              [YGTools stringFromDate:[NSDate date]],
                              [NSNull null],
                              @0, // attach
                              @104,
                              [NSNull null],
                              ],
                          @[
                              @1, // account
                              @"Тасины подарочные",
                              [NSNull null],
                              @0,
                              @1, // rub
                              @1, // active
                              [YGTools stringFromDate:[NSDate date]],
                              [NSNull null],
                              @0, // attach
                              @105,
                              [NSNull null],
                              ],
                          ];
    
    NSString *insertSQL = @"INSERT INTO entity (entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [self fillTable:@"entity" items:entities updateSQL:insertSQL];

}


- (void)addTestOperations {
    
    //static NSString *const kDateTimeFormat = @"yyyy-MM-dd HH:mm:ss Z";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    
    NSString *string20170620154530 = @"2017-06-20 15:45:30 +0300";
    NSDate *date20170620154530 = [formatter dateFromString:string20170620154530];

    NSString *string20170620154630 = @"2017-06-20 15:46:30 +0300";
    NSDate *date20170620154630 = [formatter dateFromString:string20170620154630];
    
    NSString *string20170620164630 = @"2017-06-20 16:46:30 +0300";
    NSDate *date20170620164630 = [formatter dateFromString:string20170620164630];
    
    NSString *string20170620174630 = @"2017-06-20 17:46:30 +0300";
    NSDate *date20170620174630 = [formatter dateFromString:string20170620174630];
    
    NSString *string20170621174630 = @"2017-06-21 17:46:30 +0300";
    NSDate *date20170621174630 = [formatter dateFromString:string20170621174630];
    
    NSString *string20170622174630 = @"2017-06-22 17:46:30 +0300";
    NSDate *date20170622174630 = [formatter dateFromString:string20170622174630];

    NSString *string20170623174630 = @"2017-06-23 17:46:30 +0300";
    NSDate *date20170623174630 = [formatter dateFromString:string20170623174630];
    
    NSString *string20170624150000 = @"2017-06-24 15:00:00 +0300";
    NSDate *date20170624150000 = [formatter dateFromString:string20170624150000];
    
    NSString *string20170624150001 = @"2017-06-24 15:00:01 +0300";
    NSDate *date20170624150001 = [formatter dateFromString:string20170624150001];

    NSString *string20170624150002 = @"2017-06-24 15:00:02 +0300";
    NSDate *date20170624150002 = [formatter dateFromString:string20170624150002];
    
    NSString *string20170624150003 = @"2017-06-24 15:00:03 +0300";
    NSDate *date20170624150003 = [formatter dateFromString:string20170624150003];
    
    NSString *string20170624150004 = @"2017-06-24 15:00:04 +0300";
    NSDate *date20170624150004 = [formatter dateFromString:string20170624150004];
    
    NSString *string20170625150004 = @"2017-06-25 15:00:04 +0300";
    NSDate *date20170625150004 = [formatter dateFromString:string20170625150004];
    
    NSString *string20170626150000 = @"2017-06-26 15:00:00 +0300";
    NSDate *date20170626150000 = [formatter dateFromString:string20170626150000];
    
    NSString *string20170626150001 = @"2017-06-26 15:00:01 +0300";
    NSDate *date20170626150001 = [formatter dateFromString:string20170626150001];
    
    NSString *string20170626150002 = @"2017-06-26 15:00:02 +0300";
    NSDate *date20170626150002 = [formatter dateFromString:string20170626150002];
    
    NSString *string20170626150003 = @"2017-06-26 15:00:03 +0300";
    NSDate *date20170626150003 = [formatter dateFromString:string20170626150003];
    
    NSString *string20170627150000 = @"2017-06-27 15:00:00 +0300";
    NSDate *date20170627150000 = [formatter dateFromString:string20170627150000];
    
    NSString *string20170627150001 = @"2017-06-27 15:00:01 +0300";
    NSDate *date20170627150001 = [formatter dateFromString:string20170627150001];
    
    NSString *string20170627150002 = @"2017-06-27 15:00:02 +0300";
    NSDate *date20170627150002 = [formatter dateFromString:string20170627150002];
    
    NSString *string20170627150003 = @"2017-06-27 15:00:03 +0300";
    NSDate *date20170627150003 = [formatter dateFromString:string20170627150003];
    
    NSString *string20170627150004 = @"2017-06-27 15:00:04 +0300";
    NSDate *date20170627150004 = [formatter dateFromString:string20170627150004];
    
    NSString *string20170627150005 = @"2017-06-27 15:00:05 +0300";
    NSDate *date20170627150005 = [formatter dateFromString:string20170627150005];
    
    NSString *string20170628150000 = @"2017-06-28 15:00:00 +0300";
    NSDate *date20170628150000 = [formatter dateFromString:string20170628150000];
    
    NSString *string20170628150001 = @"2017-06-28 15:00:01 +0300";
    NSDate *date20170628150001 = [formatter dateFromString:string20170628150001];
    
    NSString *string20170628150002 = @"2017-06-28 15:00:02 +0300";
    NSDate *date20170628150002 = [formatter dateFromString:string20170628150002];
    
    NSString *string20170629150000 = @"2017-06-29 15:00:00 +0300";
    NSDate *date20170629150000 = [formatter dateFromString:string20170629150000];
    
    NSString *string20170629150001 = @"2017-06-29 15:00:01 +0300";
    NSDate *date20170629150001 = [formatter dateFromString:string20170629150001];
    
    NSString *string20170630150000 = @"2017-06-30 15:00:00 +0300";
    NSDate *date20170630150000 = [formatter dateFromString:string20170630150000];
    
    NSString *string20170630150001 = @"2017-06-30 15:00:01 +0300";
    NSDate *date20170630150001 = [formatter dateFromString:string20170630150001];
    
    NSString *string20170701150000 = @"2017-07-01 15:00:00 +0300";
    NSDate *date20170701150000 = [formatter dateFromString:string20170701150000];
    
    NSString *string20170701150001 = @"2017-07-01 15:00:01 +0300";
    NSDate *date20170701150001 = [formatter dateFromString:string20170701150001];
    
    NSString *string20170701150002 = @"2017-07-01 15:00:02 +0300";
    NSDate *date20170701150002 = [formatter dateFromString:string20170701150002];
    
    NSString *string20170701150003 = @"2017-07-01 15:00:03 +0300";
    NSDate *date20170701150003 = [formatter dateFromString:string20170701150003];
    
    NSString *string20170701150004 = @"2017-07-01 15:00:04 +0300";
    NSDate *date20170701150004 = [formatter dateFromString:string20170701150004];
    
    NSString *string20170701150005 = @"2017-07-01 15:00:05 +0300";
    NSDate *date20170701150005 = [formatter dateFromString:string20170701150005];
    
    NSString *string20170702150000 = @"2017-07-02 15:00:00 +0300";
    NSDate *date20170702150000 = [formatter dateFromString:string20170702150000];
    
    NSString *string20170702150001 = @"2017-07-02 15:00:01 +0300";
    NSDate *date20170702150001 = [formatter dateFromString:string20170702150001];
    
    NSString *string20170702150002 = @"2017-07-02 15:00:02 +0300";
    NSDate *date20170702150002 = [formatter dateFromString:string20170702150002];
    
    NSString *string20170702150003 = @"2017-07-02 15:00:03 +0300";
    NSDate *date20170702150003 = [formatter dateFromString:string20170702150003];
    
    NSString *string20170702150004 = @"2017-07-02 15:00:04 +0300";
    NSDate *date20170702150004 = [formatter dateFromString:string20170702150004];
    
    NSString *string20170703150000 = @"2017-07-03 15:00:00 +0300";
    NSDate *date20170703150000 = [formatter dateFromString:string20170703150000];
    
    NSString *string20170703150001 = @"2017-07-03 15:00:01 +0300";
    NSDate *date20170703150001 = [formatter dateFromString:string20170703150001];
    
    NSString *string20170703150002 = @"2017-07-03 15:00:02 +0300";
    NSDate *date20170703150002 = [formatter dateFromString:string20170703150002];
    
    NSString *string20170703150003 = @"2017-07-03 15:00:03 +0300";
    NSDate *date20170703150003 = [formatter dateFromString:string20170703150003];
    
    NSString *string20170704150000 = @"2017-07-04 15:00:00 +0300";
    NSDate *date20170704150000 = [formatter dateFromString:string20170704150000];
    
    NSString *string20170705150000 = @"2017-07-05 15:00:00 +0300";
    NSDate *date20170705150000 = [formatter dateFromString:string20170705150000];
    
    NSString *string20170705150001 = @"2017-07-05 15:00:01 +0300";
    NSDate *date20170705150001 = [formatter dateFromString:string20170705150001];
    
    NSString *string20170706150000 = @"2017-07-06 15:00:00 +0300";
    NSDate *date20170706150000 = [formatter dateFromString:string20170706150000];
    
    NSString *string20170706150001 = @"2017-07-06 15:00:01 +0300";
    NSDate *date20170706150001 = [formatter dateFromString:string20170706150001];
    
    NSString *string20170707150000 = @"2017-07-07 15:00:00 +0300";
    NSDate *date20170707150000 = [formatter dateFromString:string20170707150000];
    
    NSString *string20170709150000 = @"2017-07-09 15:00:00 +0300";
    NSDate *date20170709150000 = [formatter dateFromString:string20170709150000];
    
    NSString *string20170709150001 = @"2017-07-01 15:00:00 +0300";
    NSDate *date20170709150001 = [formatter dateFromString:string20170709150001];
    
    NSString *string20170710150000 = @"2017-07-10 15:00:00 +0300";
    NSDate *date20170710150000 = [formatter dateFromString:string20170710150000];
    
    NSString *string20170710150001 = @"2017-07-10 15:00:01 +0300";
    NSDate *date20170710150001 = [formatter dateFromString:string20170710150001];
    
    NSString *string20170710150002 = @"2017-07-10 15:00:02 +0300";
    NSDate *date20170710150002 = [formatter dateFromString:string20170710150002];
    
    NSString *string20170710150003 = @"2017-07-10 15:00:03 +0300";
    NSDate *date20170710150003 = [formatter dateFromString:string20170710150003];
    
    NSString *string20170711150000 = @"2017-07-11 15:00:00 +0300";
    NSDate *date20170711150000 = [formatter dateFromString:string20170711150000];
    
    NSString *string20170712150000 = @"2017-07-12 15:00:00 +0300";
    NSDate *date20170712150000 = [formatter dateFromString:string20170712150000];
    
    NSString *string20170713150000 = @"2017-07-13 15:00:00 +0300";
    NSDate *date20170713150000 = [formatter dateFromString:string20170713150000];
    
    NSString *string20170713150001 = @"2017-07-13 15:00:01 +0300";
    NSDate *date20170713150001 = [formatter dateFromString:string20170713150001];
    
    NSString *string20170714150000 = @"2017-07-14 15:00:00 +0300";
    NSDate *date20170714150000 = [formatter dateFromString:string20170714150000];
    
    NSString *string20170714150001 = @"2017-07-14 15:00:01 +0300";
    NSDate *date20170714150001 = [formatter dateFromString:string20170714150001];
    
    NSString *string20170716150000 = @"2017-07-16 15:00:00 +0300";
    NSDate *date20170716150000 = [formatter dateFromString:string20170716150000];
    
    NSString *string20170717150000 = @"2017-07-17 15:00:00 +0300";
    NSDate *date20170717150000 = [formatter dateFromString:string20170717150000];
    
    NSString *string20170717150001 = @"2017-07-17 15:00:01 +0300";
    NSDate *date20170717150001 = [formatter dateFromString:string20170717150001];
    
    NSString *string20170717150002 = @"2017-07-17 15:00:02 +0300";
    NSDate *date20170717150002 = [formatter dateFromString:string20170717150002];
    
    NSString *string20170717150003 = @"2017-07-17 15:00:03 +0300";
    NSDate *date20170717150003 = [formatter dateFromString:string20170717150003];
    
    NSString *string20170717150004 = @"2017-07-17 15:00:04 +0300";
    NSDate *date20170717150004 = [formatter dateFromString:string20170717150004];
    
    NSString *string20170718150000 = @"2017-07-18 15:00:00 +0300";
    NSDate *date20170718150000 = [formatter dateFromString:string20170718150000];
    
    NSString *string20170718150001 = @"2017-07-18 15:00:01 +0300";
    NSDate *date20170718150001 = [formatter dateFromString:string20170718150001];
    
    NSString *string20170718150002 = @"2017-07-18 15:00:02 +0300";
    NSDate *date20170718150002 = [formatter dateFromString:string20170718150002];
    
    NSString *string20170718150003 = @"2017-07-18 15:00:03 +0300";
    NSDate *date20170718150003 = [formatter dateFromString:string20170718150003];
    
    NSString *string20170718150004 = @"2017-07-18 15:00:04 +0300";
    NSDate *date20170718150004 = [formatter dateFromString:string20170718150004];
    
    //
    
    NSString *string20170719150000 = @"2017-07-19 15:00:00 +0300";
    NSDate *date20170719150000 = [formatter dateFromString:string20170719150000];
    
    NSString *string20170719150001 = @"2017-07-19 15:00:01 +0300";
    NSDate *date20170719150001 = [formatter dateFromString:string20170719150001];
    
    NSString *string20170719150002 = @"2017-07-19 15:00:02 +0300";
    NSDate *date20170719150002 = [formatter dateFromString:string20170719150002];
    
    NSString *string20170719150003 = @"2017-07-19 15:00:03 +0300";
    NSDate *date20170719150003 = [formatter dateFromString:string20170719150003];
    
    NSString *string20170719150004 = @"2017-07-19 15:00:04 +0300";
    NSDate *date20170719150004 = [formatter dateFromString:string20170719150004];
    
    NSString *string20170719150005 = @"2017-07-19 15:00:05 +0300";
    NSDate *date20170719150005 = [formatter dateFromString:string20170719150005];
    
    NSString *string20170719150006 = @"2017-07-19 15:00:06 +0300";
    NSDate *date20170719150006 = [formatter dateFromString:string20170719150006];
    
    NSString *string20170719150007 = @"2017-07-19 15:00:07 +0300";
    NSDate *date20170719150007 = [formatter dateFromString:string20170719150007];
    
    NSString *string20170719150008 = @"2017-07-19 15:00:08 +0300";
    NSDate *date20170719150008 = [formatter dateFromString:string20170719150008];
    
    NSString *string20170719150009 = @"2017-07-19 15:00:09 +0300";
    NSDate *date20170719150009 = [formatter dateFromString:string20170719150009];
    
    //
    
    NSString *string20170719150010 = @"2017-07-19 15:00:10 +0300";
    NSDate *date20170719150010 = [formatter dateFromString:string20170719150010];
    
    NSString *string20170719150011 = @"2017-07-19 15:00:11 +0300";
    NSDate *date20170719150011 = [formatter dateFromString:string20170719150011];
    
    NSString *string20170719150012 = @"2017-07-19 15:00:12 +0300";
    NSDate *date20170719150012 = [formatter dateFromString:string20170719150012];
    
    NSString *string20170719150013 = @"2017-07-19 15:00:13 +0300";
    NSDate *date20170719150013 = [formatter dateFromString:string20170719150013];
    
    //
    
    NSString *string20170720150000 = @"2017-07-20 15:00:00 +0300";
    NSDate *date20170720150000 = [formatter dateFromString:string20170720150000];
    
    NSString *string20170720150001 = @"2017-07-20 15:00:01 +0300";
    NSDate *date20170720150001 = [formatter dateFromString:string20170720150001];
    
    NSString *string20170720150002 = @"2017-07-20 15:00:02 +0300";
    NSDate *date20170720150002 = [formatter dateFromString:string20170720150002];


    
    
    
    // fill category - income sources
    NSArray *operations = @[
                            @[// остаток по счету Кошелек Ян
                                @3,         // operation_type_id = остаток
                                @1,         // source_id = account Кошелек Ян
                                @1,         // target_id = account Кошелек Ян
                                @11250.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @11250.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170620154530, // date
                                [NSNumber numberWithDouble:[date20170620154530 timeIntervalSince1970]],  // date_unix
                                [NSNull null]             // comment
                                ],
                            @[// остаток по счету Кошелек Маша
                                @3,         // operation_type_id = остаток
                                @2,         // source_id = account Кошелек Маша
                                @2,         // target_id = account Кошелек Маша
                                @2043.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @2043.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170620154630, // date
                                [NSNumber numberWithDouble:[date20170620154630 timeIntervalSince1970]],  // date_unix
                                @"Test data"             // comment
                                ],
                            @[ // остаток по карте Сбербанк
                                @3,         // operation_type_id = остаток
                                @3,         // source_id = account Карта Сбербанк
                                @3,         // target_id = account Карта Сбербанк
                                @3220.15,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @3220.15,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170620164630, // date
                                [NSNumber numberWithDouble:[date20170620164630 timeIntervalSince1970]],  // date_unix
                                @"Test data"             // comment
                                ],
                            @[ // остаток Заначка в рублях
                                @3,         // operation_type_id = остаток
                                @4,         // source_id = account Заначка в рублях
                                @4,         // target_id = account Заначка в рублях
                                @47000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @47000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170620174630, // date
                                [NSNumber numberWithDouble:[date20170620174630 timeIntervalSince1970]],  // date_unix
                                @"Test data"             // comment
                                ],
                            @[ // остаток по Заначка в $
                                @3,         // operation_type_id = остаток
                                @5,         // source_id = account Заначка в $
                                @5,         // target_id = account Заначка в $
                                @1075.00,           // source_sum = 1075.00
                                @5,             // source_currency_id = 1
                                @1075.00,               // target_sum = 1075.00
                                @5,           // target_currency_id = 1
                                string20170620174630, // date
                                [NSNumber numberWithDouble:[date20170620174630 timeIntervalSince1970]],  // date_unix
                                @"Test data"             // comment
                                ],
                            @[ // бензин
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account наличные
                                @22,         // target_id = expenseCategory
                                @1000.00,           // source_sum =
                                @1,             // source_currency_id = 1
                                @1000.00,               // target_sum
                                @1,           // target_currency_id = 1
                                string20170620174630, // date
                                [NSNumber numberWithDouble:[date20170620174630 timeIntervalSince1970]],  // date_unix
                                @"Бензин"             // comment
                                ],
                            @[ // прием у ветеринара
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @26,         // target_id = expenseCategory Кошки
                                @400.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @400.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Прием у ветеринара"             // comment
                                ],
                            @[ // продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @11,         // target_id = expenseCategory продукты
                                @630.00,           // source_sum =
                                @1,             // source_currency_id = 1
                                @630.00,               // target_sum =
                                @1,           // target_currency_id = 1
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Продукты Маша"             // comment
                                ],
                            @[ // продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @11,         // target_id = expenseCategory продукты
                                @615.00,           // source_sum =
                                @1,             // source_currency_id = 1
                                @615.00,               // target_sum
                                @1,           // target_currency_id = 1
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Продукты Маша"             // comment
                                ],
                            @[ // ян -> маша
                                @4,         // operation_type_id = перевод
                                @1,         // source_id = account Кошелек Ян
                                @2,         // target_id = account Кошелек Маша
                                @1000.00,           // source_sum
                                @1,             // source_currency_id = 1
                                @1000.00,               // target_sum
                                @1,           // target_currency_id = 1
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Ян -> Маша"             // comment
                                ],
                            @[ // электроэнергия
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @13,         // target_id = expenseCategory Дом
                                @901.24,           // source_sum
                                @1,             // source_currency_id = 1
                                @901.24,               // target_sum
                                @1,           // target_currency_id = 1
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Электроэнергия"             // comment
                                ],
                            @[ // кот
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @26,         // target_id = expenseCategory Кошки
                                @305.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @305.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Кот"             // comment
                                ],
                            @[ // продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @11,         // target_id = expenseCategory продукты
                                @203.00,    // source_sum
                                @1,         // source_currency_id = рубль
                                @203.00,    // target_sum
                                @1,         // target_currency_id = рубль
                                string20170621174630, // date
                                [NSNumber numberWithDouble:[date20170621174630 timeIntervalSince1970]],  // date_unix
                                @"Продукты"             // comment
                                ],
                            @[ // заначка руб -> ян
                                @4,         // operation_type_id = перевод
                                @4,         // source_id = account Заначка в рублях
                                @1,         // target_id = account Кошелек Ян
                                @15000.00,  // source_sum
                                @1,         // source_currency_id = рубль
                                @15000.00,  // target_sum
                                @1,         // target_currency_id = рубль
                                string20170622174630, // date
                                [NSNumber numberWithDouble:[date20170622174630 timeIntervalSince1970]],  // date_unix
                                @"Заначка в рублях -> Ян"             // comment
                                ],
                            @[ // ян -> сбербанк
                                @4,         // operation_type_id = перевод
                                @1,         // source_id = account Кошелек Ян
                                @3,         // target_id = account Карта Сбербанк
                                @15000.00,           // source_sum
                                @1,             // source_currency_id = рубль
                                @15000.00,               // target_sum
                                @1,           // target_currency_id = рубль
                                string20170622174630, // date
                                [NSNumber numberWithDouble:[date20170622174630 timeIntervalSince1970]],  // date_unix
                                @"Ян -> Карта Сбербанк"             // comment
                                ],
                            @[ // продукты
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @11,         // target_id = expenseCategory продукты
                                @339.00,           // source_sum
                                @1,             // source_currency_id = 1
                                @339.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170622174630, // date
                                [NSNumber numberWithDouble:[date20170622174630 timeIntervalSince1970]],  // date_unix
                                @"Продукты"             // comment
                                ],
                            @[ // одежда тасе
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @33,         // target_id = expenseCategory продукты
                                @345.50,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @345.50,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170623174630, // date
                                [NSNumber numberWithDouble:[date20170623174630 timeIntervalSince1970]],  // date_unix
                                @"Одежда тасе"             // comment
                                ],
                            @[ // кот
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account Кошелек Маша
                                @26,         // target_id = expenseCategory Кошки
                                @1000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170623174630, // date
                                [NSNumber numberWithDouble:[date20170623174630 timeIntervalSince1970]],  // date_unix
                                @"УЗИ Филимону"             // comment
                                ],
                            @[ // продукты
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @11,         // target_id = expenseCategory продукты
                                @622.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @622.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170623174630, // date
                                [NSNumber numberWithDouble:[date20170623174630 timeIntervalSince1970]],  // date_unix
                                @"Продукты"             // comment
                                ],
                            @[ // сбербанк - одежда
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @17,         // target_id = expenseCategory продукты
                                @1200.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1200.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170624150000, // date
                                [NSNumber numberWithDouble:[date20170624150000 timeIntervalSince1970]],  // date_unix
                                @"Платье Маше?"             // comment
                                ],
                            @[ // сбербанк - Гигиена
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @19,         // target_id = expenseCategory
                                @935.26,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @935.26,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170624150001, // date
                                [NSNumber numberWithDouble:[date20170624150001 timeIntervalSince1970]],  // date_unix
                                @"Ашан?"             // comment
                                ],
                            @[ // сбербанк - Хозяйство
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @13,         // target_id = expenseCategory
                                @186.04,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @186.04,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170624150002, // date
                                [NSNumber numberWithDouble:[date20170624150002 timeIntervalSince1970]],  // date_unix
                                @"Ашан?"             // comment
                                ],
                            @[ // сбербанк - кот
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @26,         // target_id = expenseCategory
                                @41.98,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @41.98,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170624150003, // date
                                [NSNumber numberWithDouble:[date20170624150003 timeIntervalSince1970]],  // date_unix
                                @"Ашан?"             // comment
                                ],
                            @[ // сбербанк - продукты
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @11,         // target_id = expenseCategory
                                @4857.32,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @4857.32,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170624150004, // date
                                [NSNumber numberWithDouble:[date20170624150004 timeIntervalSince1970]],  // date_unix
                                @"Ашан?"             // comment
                                ],
                            @[ // сбербанк - кот
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @26,         // target_id = expenseCategory
                                @330.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @330.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170625150004, // date
                                [NSNumber numberWithDouble:[date20170625150004 timeIntervalSince1970]],  // date_unix
                                @"Ашан?"             // comment
                                ],
                            @[ // сбербанк - коммуналка
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account Карта Сбербанк
                                @13,         // target_id = expenseCategory
                                @5164.51,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @5164.51,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170626150000, // date
                                [NSNumber numberWithDouble:[date20170626150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - маша
                                @4,         // operation_type_id = expense
                                @1,         // source_id = account ян
                                @2,         // target_id = account машан
                                @5000,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @5000,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170626150002, // date
                                [NSNumber numberWithDouble:[date20170626150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - прическа
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @20,         // target_id = expenseCategory
                                @700.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @700.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170626150003, // date
                                [NSNumber numberWithDouble:[date20170626150003 timeIntervalSince1970]],  // date_unix
                                @"Прическа Маша"             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @65.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @65.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150000, // date
                                [NSNumber numberWithDouble:[date20170627150000 timeIntervalSince1970]],  // date_unix
                                @"Прическа Маша"             // comment
                                ],
                            @[ // маша - ян
                                @4,         // operation_type_id = expense
                                @2,         // source_id = account ян
                                @1,         // target_id = account машан
                                @2000,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @2000,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150001, // date
                                [NSNumber numberWithDouble:[date20170627150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @115.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @115.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150001, // date
                                [NSNumber numberWithDouble:[date20170627150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // сбербанк - здоровье
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account сбербанк
                                @18,         // target_id = expenseCategory
                                @402.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @402.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150002, // date
                                [NSNumber numberWithDouble:[date20170627150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @709.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @709.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150003, // date
                                [NSNumber numberWithDouble:[date20170627150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @307.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @307.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150004, // date
                                [NSNumber numberWithDouble:[date20170627150004 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @156.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @156.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170627150005, // date
                                [NSNumber numberWithDouble:[date20170627150005 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // сбербанк - здоровье
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @18,         // target_id = expenseCategory
                                @30.70,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @30.70,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170628150000, // date
                                [NSNumber numberWithDouble:[date20170628150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // сбербанк - здоровье
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @18,         // target_id = expenseCategory
                                @38.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @38.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170628150001, // date
                                [NSNumber numberWithDouble:[date20170628150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @802.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @802.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170628150002, // date
                                [NSNumber numberWithDouble:[date20170628150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @127.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @127.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170629150000, // date
                                [NSNumber numberWithDouble:[date20170629150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - таисия
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @33,         // target_id = expenseCategory
                                @897.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @897.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170629150001, // date
                                [NSNumber numberWithDouble:[date20170629150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @20.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @20.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170630150000, // date
                                [NSNumber numberWithDouble:[date20170630150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @137.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @137.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170630150001, // date
                                [NSNumber numberWithDouble:[date20170630150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // маша - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @26,         // target_id = expenseCategory
                                @350.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @350.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170701150000, // date
                                [NSNumber numberWithDouble:[date20170701150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @546.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @546.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170701150001, // date
                                [NSNumber numberWithDouble:[date20170701150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // заначка - ян
                                @4,         // operation_type_id = expense
                                @4,         // source_id = account ян
                                @1,         // target_id = account машан
                                @5000,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @5000,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170701150002, // date
                                [NSNumber numberWithDouble:[date20170701150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @188.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @188.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170701150003, // date
                                [NSNumber numberWithDouble:[date20170701150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @428.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @428.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170701150004, // date
                                [NSNumber numberWithDouble:[date20170701150004 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @26,         // target_id = expenseCategory
                                @1062.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1062.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170701150005, // date
                                [NSNumber numberWithDouble:[date20170701150005 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @18,         // target_id = expenseCategory
                                @1084.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1084.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170702150000, // date
                                [NSNumber numberWithDouble:[date20170702150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @202.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @202.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170702150001, // date
                                [NSNumber numberWithDouble:[date20170702150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @154.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @154.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170702150002, // date
                                [NSNumber numberWithDouble:[date20170702150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @564.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @564.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170702150003, // date
                                [NSNumber numberWithDouble:[date20170702150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @785.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @785.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170702150004, // date
                                [NSNumber numberWithDouble:[date20170702150004 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @22,         // target_id = expenseCategory
                                @1321.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1321.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170703150000, // date
                                [NSNumber numberWithDouble:[date20170703150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @482.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @482.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170703150001, // date
                                [NSNumber numberWithDouble:[date20170703150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @386.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @386.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170703150002, // date
                                [NSNumber numberWithDouble:[date20170703150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @949.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @949.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170703150003, // date
                                [NSNumber numberWithDouble:[date20170703150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @237.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @237.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170704150000, // date
                                [NSNumber numberWithDouble:[date20170704150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @185.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @185.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170705150000, // date
                                [NSNumber numberWithDouble:[date20170705150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @4,         // operation_type_id = expense
                                @4,         // source_id = account маша
                                @2,         // target_id = expenseCategory
                                @15000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @15000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170705150001, // date
                                [NSNumber numberWithDouble:[date20170705150001 timeIntervalSince1970]],  // date_unix
                                @"Заначка - Маша"             // comment
                                ],
                            @[ // ян - продукты
                                @4,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @3,         // target_id = expenseCategory
                                @10000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @10000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170706150000, // date
                                [NSNumber numberWithDouble:[date20170706150000 timeIntervalSince1970]],  // date_unix
                                @"Заначка - Маша"             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @514.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @514.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170706150001, // date
                                [NSNumber numberWithDouble:[date20170706150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @3,         // source_id = account маша
                                @15,         // target_id = expenseCategory
                                @4400.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @4400.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170707150000, // date
                                [NSNumber numberWithDouble:[date20170707150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @333.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @333.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170709150000, // date
                                [NSNumber numberWithDouble:[date20170709150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @116.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @116.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170709150001, // date
                                [NSNumber numberWithDouble:[date20170709150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @255.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @255.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170710150000, // date
                                [NSNumber numberWithDouble:[date20170710150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @20,         // target_id = expenseCategory
                                @569.70,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @569.70,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170710150001, // date
                                [NSNumber numberWithDouble:[date20170710150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @19,         // target_id = expenseCategory
                                @369.42,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @369.42,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170710150002, // date
                                [NSNumber numberWithDouble:[date20170710150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @20,         // target_id = expenseCategory
                                @327.01,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @327.01,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170710150003, // date
                                [NSNumber numberWithDouble:[date20170710150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @162.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @162.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170711150000, // date
                                [NSNumber numberWithDouble:[date20170711150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @386.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @386.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170712150000, // date
                                [NSNumber numberWithDouble:[date20170712150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @131.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @131.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170713150000, // date
                                [NSNumber numberWithDouble:[date20170713150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @171.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @171.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170713150001, // date
                                [NSNumber numberWithDouble:[date20170713150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @13,         // target_id = expenseCategory
                                @549.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @549.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170714150000, // date
                                [NSNumber numberWithDouble:[date20170714150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @375.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @375.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170714150001, // date
                                [NSNumber numberWithDouble:[date20170714150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @4,         // operation_type_id = expense
                                @4,         // source_id = account маша
                                @1,         // target_id = expenseCategory
                                @5000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @5000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170714150001, // date
                                [NSNumber numberWithDouble:[date20170714150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @109.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @109.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170717150000, // date
                                [NSNumber numberWithDouble:[date20170717150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @373.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @373.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170717150001, // date
                                [NSNumber numberWithDouble:[date20170717150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @26,         // target_id = expenseCategory
                                @1133.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1133.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170717150002, // date
                                [NSNumber numberWithDouble:[date20170717150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @22,         // target_id = expenseCategory
                                @1000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170717150003, // date
                                [NSNumber numberWithDouble:[date20170717150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @4,         // operation_type_id = expense
                                @3,         // source_id = account маша
                                @2,         // target_id = expenseCategory
                                @3000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @3000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170717150004, // date
                                [NSNumber numberWithDouble:[date20170717150004 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @626.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @626.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170718150000, // date
                                [NSNumber numberWithDouble:[date20170718150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account маша
                                @14,         // target_id = expenseCategory
                                @300.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @300.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170718150001, // date
                                [NSNumber numberWithDouble:[date20170718150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @4,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @1,         // target_id = expenseCategory
                                @1000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170718150002, // date
                                [NSNumber numberWithDouble:[date20170718150002 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @506.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @506.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170718150003, // date
                                [NSNumber numberWithDouble:[date20170718150003 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account маша
                                @11,         // target_id = expenseCategory
                                @181.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @181.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170718150004, // date
                                [NSNumber numberWithDouble:[date20170718150004 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - остаток
                                @3,         // operation_type_id = expense
                                @1,         // source_id = account
                                @1,         // target_id = expenseCategory
                                @5350.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @5350.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150000, // date
                                [NSNumber numberWithDouble:[date20170719150000 timeIntervalSince1970]],  // date_unix
                                @"Кажет 11623"             // comment
                                ],
                            @[ // маша - остаток
                                @3,         // operation_type_id = expense
                                @2,         // source_id = account
                                @2,         // target_id = expenseCategory
                                @7850.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @7850.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150001, // date
                                [NSNumber numberWithDouble:[date20170719150001 timeIntervalSince1970]],  // date_unix
                                @"Кажет -6337"             // comment
                                ],
                            @[ // заначка Р - остаток
                                @3,         // operation_type_id = expense
                                @4,         // source_id = account
                                @4,         // target_id = expenseCategory
                                @0.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @0.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150002, // date
                                [NSNumber numberWithDouble:[date20170719150002 timeIntervalSince1970]],  // date_unix
                                @"Кажет 7000"             // comment
                                ],
                            @[ // Сбербанк - остаток
                                @3,         // operation_type_id = expense
                                @3,         // source_id = account
                                @3,         // target_id = expenseCategory
                                @2856.16,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @2856.16,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150003, // date
                                [NSNumber numberWithDouble:[date20170719150003 timeIntervalSince1970]],  // date_unix
                                @"Кажет 5844"             // comment
                                ],
                            @[ // Сбербанк - остаток
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account
                                @11,         // target_id = expenseCategory
                                @116.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @116.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150004, // date
                                [NSNumber numberWithDouble:[date20170719150004 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // заначка Р - заначка $
                                @4,         // operation_type_id = expense
                                @5,         // source_id = account
                                @4,         // target_id = expenseCategory
                                @1081.00,           // source_sum = 1500.00
                                @2,             // source_currency_id = 1
                                @63476.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150005, // date
                                [NSNumber numberWithDouble:[date20170719150005 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // заначка Р - ян
                                @4,         // operation_type_id = expense
                                @4,         // source_id = account
                                @1,         // target_id = expenseCategory
                                @10000.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @10000.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150006, // date
                                [NSNumber numberWithDouble:[date20170719150006 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - одежда
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @17,         // target_id = expenseCategory
                                @699.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @699.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150007, // date
                                [NSNumber numberWithDouble:[date20170719150007 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - одежда
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @17,         // target_id = expenseCategory
                                @649.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @649.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150008, // date
                                [NSNumber numberWithDouble:[date20170719150008 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - одежда
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @17,         // target_id = expenseCategory
                                @2197.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @2197.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150009, // date
                                [NSNumber numberWithDouble:[date20170719150009 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - одежда
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @17,         // target_id = expenseCategory
                                @800.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @800.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150010, // date
                                [NSNumber numberWithDouble:[date20170719150010 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - одежда
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @17,         // target_id = expenseCategory
                                @4439.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @4439.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150011, // date
                                [NSNumber numberWithDouble:[date20170719150011 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account
                                @11,         // target_id = expenseCategory
                                @673.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @673.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150012, // date
                                [NSNumber numberWithDouble:[date20170719150012 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @2,         // source_id = account
                                @11,         // target_id = expenseCategory
                                @47.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @47.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170719150013, // date
                                [NSNumber numberWithDouble:[date20170719150013 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @11,         // target_id = expenseCategory
                                @497.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @497.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170720150000, // date
                                [NSNumber numberWithDouble:[date20170720150000 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @1,         // operation_type_id = expense
                                @45,         // source_id = account
                                @1,         // target_id = expenseCategory
                                @500.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @500.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170720150001, // date
                                [NSNumber numberWithDouble:[date20170720150001 timeIntervalSince1970]],  // date_unix
                                @""             // comment
                                ],
                            @[ // ян - продукты
                                @2,         // operation_type_id = expense
                                @1,         // source_id = account
                                @20,         // target_id = expenseCategory
                                @1010.00,           // source_sum = 1500.00
                                @1,             // source_currency_id = 1
                                @1010.00,               // target_sum = 1500.00
                                @1,           // target_currency_id = 1
                                string20170720150002, // date
                                [NSNumber numberWithDouble:[date20170720150002 timeIntervalSince1970]],  // date_unix
                                @"Маникюр"             // comment
                                ],
                            ];
    
    NSString *insertSQL = @"INSERT INTO operation (operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, date, date_unix, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [self fillTable:@"operation" items:operations updateSQL:insertSQL];
    
}

- (void)addTestExpenseCategories {
    
    // fill category - expences category
    NSArray *сategories = @[
                            @[
                                @2,
                                @"Продукты",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Чревоугодия",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @11,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Хозяйство",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Консьерж",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @13,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Смоленская квартира",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @13,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Ремонт/Мебель",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @102,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @13,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Одежда",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @102,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Здоровье",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @103,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Гигиена",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @18,
                                [NSNull null],
                                ],
                            @[
                                @2, // category_type_id
                                @"Красота", // name
                                @1, // active
                                [YGTools stringFromDate:[NSDate date]], // active_from
                                [NSNull null], // active_to
                                @101, // sort
                                [NSNull null], // short_name
                                [NSNull null],  // symbol
                                @0, // attach
                                @18, // parent_id
                                [NSNull null], // comment
                                ],
                            @[
                                @2,
                                @"Транспорт",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @104,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Матрёшка",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @21,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Связь",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @105,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Образование",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @106,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Развлечения",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @107,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Кошки",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @25,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Рукоделия",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @25,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Книги",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @102,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @25,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Кино/музыка",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @103,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @25,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Отдых",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @104,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @25,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Фото",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @105,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @25,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Семья",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @108,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Таисия",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @32,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Смоляне",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @32,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Кум/кума/крестник",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @102,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @32,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Деловое",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @109,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Компьютерра",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @36,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Канцелярщина",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @36,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Банковские расходы",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @102,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @36,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Государство",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @110,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Налоги",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @40,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Штрафы",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @101,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                @40,
                                [NSNull null],
                                ],
                            @[
                                @2,
                                @"Потери",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @111,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            ];
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [self fillTable:@"category" items:сategories updateSQL:insertSQL];
}

- (void)addTestIncomeSources {
    
    // fill category - income sources
    NSArray *сategories = @[
                            @[
                                @3,
                                @"Зарплата",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @3,
                                @"Продажа имущества",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            @[
                                @3,
                                @"Подарки",
                                @1,
                                [YGTools stringFromDate:[NSDate date]],
                                [NSNull null],
                                @100,
                                [NSNull null],
                                [NSNull null],
                                @0,
                                [NSNull null],
                                [NSNull null],
                                ],
                            ];
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [self fillTable:@"category" items:сategories updateSQL:insertSQL];
    
    
}


#pragma mark - Check actions

- (void)checkDatabase{
    
    sqlite3 *db = [self database];
    
    NSLog(@"Path to db: %@", [YGSQLite databaseFullName]);

    sqlite3_close(db);
    
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


- (NSInteger)addRecord:(NSArray *)fieldsOfItem insertSQL:(NSString *)insertSQL{
    
    NSInteger resultId = -1;
    sqlite3 *db = [self database];

    //char *errorMsg = NULL;
    sqlite3_stmt *stmt;

    if(sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &stmt, nil) == SQLITE_OK){
        
        for(int i = 0; i < [fieldsOfItem count]; i++){
            
            id field = fieldsOfItem[i];
            
            if([field isKindOfClass:[NSNumber class]]){
                if(sqlite3_bind_int(stmt, i+1, [field intValue]) != SQLITE_OK){
                    NSLog(@"Can not bind int");
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

- (NSArray *)selectWithSqlQuery:(NSString *)sqlQuery bindClasses:(NSArray*)classes{
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    sqlite3 *db = [self database];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableArray *row = [[NSMutableArray alloc] init];
            
            for(int i = 0; i < [classes count]; i++){
                
                //NSLog(@"what is this: %@", classes[i]);
                
                if([classes[i] isEqual:[NSNumber class]]){
                    int intVal = sqlite3_column_int(statement, i);
                    [row addObject:[NSNumber numberWithInt:intVal]];
                }
                else if([classes[i] isEqual:[NSString class]]){
                    const char *charValue = (char *)sqlite3_column_text(statement, i);
                    if(charValue != NULL)
                        [row addObject:[[NSString alloc] initWithUTF8String:charValue]];
                    else
                        [row addObject:[NSNull null]];
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

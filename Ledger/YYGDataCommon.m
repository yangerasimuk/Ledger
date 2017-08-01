//
//  YYGDataCommon.m
//  Ledger
//
//  Created by Ян on 22/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGDataCommon.h"
#import "YGSQLite.h"
#import "YGTools.h"

void addCommonCurrencies(){
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    NSArray *categories = nil;
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        categories = @[
                       @[
                           @1,
                           @"Российский рубль",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
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
                           @"B",
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
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       ];
        
    }
    else{
        categories = @[
                       @[
                           @1,
                           @"Russian Ruble",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           @"₽",
                           @1,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Belarussian Ruble",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           @"B",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Hryvnia",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           @"₴",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Tenge",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           @"₸",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"US Dollar",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           @"$",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Euro",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           @"€",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Pound Sterling",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @106,
                           @"£",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Swiss Franc",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @107,
                           @"₣",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Yuan Renminbi",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @108,
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @1,
                           @"Yen",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @109,
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       ];
        
    }
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, symbol, attach, parent_id, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [sqlite fillTable:@"category" items:categories updateSQL:insertSQL];
}
